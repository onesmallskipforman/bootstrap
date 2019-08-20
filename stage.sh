

# funtion for staging software based on apps.json file and inputted tags
# due to the increasing complexity of these filters, this will likely be 
#   refactored into python with the python json library
stage () {

  # get input list
  IN=""

  if [[ $1 == "--all" ]]; then 
    J=$(jq -c '[.apps[].tag]' apps.json) 
  else
    for ARG in "$@"; do 
      if [[ $ARG == *.txt ]]; then ARG="$(cat $ARG)"; fi
      IN="$IN\n$ARG"
    done
    J=$(echo -e "$IN" | jq -ncR '[inputs| split(" ") | .[] | select(length>0)] | unique')
  fi

  # get full json of relevant installs, dependencies included
  J=$(
    jq -r --argjson J "$J" '
    .apps  as $A |
    .types as $T |

    def dep:
      . as $F |
      $F | map(select(.dependencies).dependencies) | flatten | unique as $D |
      $D | map( select(IN($F[].tag) | not) ) as $D | 
      $A | map(select( .tag | IN($D[]) ) ) as $D |
      if isempty($D[]) then
        $F
      else
        [$F, $D] | flatten | 
        dep
      end;

    $A | map(select( .tag | IN($J[]) ) ) | dep' apps.json
  )
  
  # populate Brewfile
  jq -r --argjson J "$J" '
    .types as $T |

    def title(s):                                "\n" +
      "#########################################  \n" +
      "# \(s)                                     \n" +
      "#########################################";

    def id(s):
      . as $J |
      $T | map(select(.tag==s))[] as $IN |
      [title($IN.title)] +
      [$J[] | select(.installType==s) | 
      "\($IN.bundle) \"\(.installName // .tag)\"" + " \(if .id then ", id: \(.id)" else "" end)"
      ]| sort;

    $J |    
    [id("tap"), id("cask"), id("brew"), id("mas")] | flatten | .[]
  ' apps.json > Brewfile
  
  # populate other scripts into install.sh
  echo -e '#!/bin/bash' >  install.sh
  jq -r --argjson J "$J" '
    .types as $T |

    def title(s):                                "\n" +
      "#########################################  \n" +
      "# \(s)                                     \n" +
      "#########################################";

    def idt(s):
      . as $J |
      $T | map(select(.tag==s))[] as $IN |
      [title($IN.title)] +
      [$J[] | select(.installType==s) | 
      "\($IN.install)" + 
      "\(if .args then "\(.args)" else "" end)" + 
      "\(if .id then "\(.id) \t# \(.tag)" else "\(.installName // .tag)" end)"
      ]| sort;

    
    $J | [idt("bundle"), idt("bash"), idt("python3"), idt("pip3"), idt("npm")] | flatten | .[]
  ' apps.json >> install.sh

  # populate quarantine script
  echo -e '#!/bin/bash\n\nsource config_funcs.sh\n'    >  quarantine.sh
  jq -r --argjson J "$J" '

    def idq:
      [.[] | select(.appname) | 
      "quar \"\(.appname)\" \(if .appdir then "\"\(.appdir)\"" else "" end)"
      ]| sort;
    
    $J | [idq] | flatten | .[]
  ' apps.json >> quarantine.sh

  # populate backup script
  echo -e '#!/bin/bash\n\nsource config_funcs.sh\n'    >  backup.sh
  jq -r --argjson J "$J" '
    .configs as $C |

    def idc:
      [.[] | select(.config) as $S | $C[] | select(.tag=="\($S.tag)") | 
      "\(.config) --backup \(if .configname then "\"\(.configname)\"" else "" end)"
      ]| sort;
    
    $J | [idc] | flatten | .[]
  ' apps.json >> backup.sh

  # populate restore script
  echo -e '#!/bin/bash\n\nsource config_funcs.sh\n'    >  restore.sh
  jq -r --argjson J "$J" '
    .configs as $C |

    def idc:
      [.[] | select(.config==true) as $S | $C[] | select(.tag=="\($S.tag)") | 
      "\(.config) --restore \(if .configname then "\"\(.configname)\"" else "" end)"
      ]| sort;
    
    $J | [idc] | flatten | .[]
  ' apps.json >> restore.sh

}












