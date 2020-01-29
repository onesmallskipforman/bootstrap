

# optional function for alphabetizing apps.json
sort () {
  SORTED=$(jq -c '. | with_entries(.value = (.value | sort_by(.tag)))' apps.json)
  jq -n --argjson SORTED "$SORTED" '$SORTED' > apps.json
}


# funtion for staging software based on apps.json file and inputted tags
# due to the increasing complexity of these filters, this will likely be
#   refactored into python with the python json library
stage () {

  # get input list
  IN=""

  if [[ $1 == "--all" ]]; then
    I=$(jq -c '.apps|map(.tag)' apps.json)
  else
    for ARG in "$@"; do
      if [[ $ARG == *.txt ]]; then ARG="$(cat $ARG)"; fi
      IN="$IN\n$ARG"
    done
    I=$(echo -e "$IN" | jq -ncR '[inputs| split(" ") | .[] | select(length>0)] | unique')
  fi

  # get full json of relevant installs, dependencies included
  J=$(
    jq --argjson I "$I" '
    .types as $T |
    .apps  as $A |
    .files as $F |

    def dep:
      . as $G |
      $G | map(select(.dependencies).dependencies) + (
      $T | map(select(.tag | IN($G[].type)).dependencies))
      | flatten | unique as $D |
      $D | map( select(IN($G[].tag) | not) ) as $D |
      $A | map(select( .tag | IN($D[]) ) ) as $D |
      if isempty($D[]) then
        $G
      else
        [$G, $D] | flatten |
        dep
      end;

    $A | map(select( .tag | IN($I[]) ) ) | dep' apps.json
  )

  # create file structures
  FILES=$(
    jq --argjson J "$J" '
    .types as $T |
    .apps  as $A |
    .files as $F |

    def dep:
      . as $G |
      $G | map(select(.dependencies).dependencies) + (
      $T | map(select(.tag | IN($G[].type)).dependencies))
      | flatten | unique as $D |
      $D | map( select(IN($G[].tag) | not) ) as $D |
      $A | map(select( .tag | IN($D[]) ) ) as $D |
      if isempty($D[]) then
        $G
      else
        [$G, $D] | flatten |
        dep
      end;

    def bigtitle(s):"\n" +
      "#===================================================================\n" +
      "# \(s)\n" +
      "#===================================================================\n\n";

    def title(s):"\n" +
      "##################################################\n" +
      "# \(s)\n" +
      "##################################################\n";

    def order($ARRAY):
      . // [null] |
      . as $ORDER |
      [$ORDER[] | . as $o | $ARRAY[] | select(.tag==$o)] +
      [$T[] | select(.tag | IN($ORDER[]) | not)];

    def idt($J):
      $F[] | . as $f | $f.order | order($T) as $TO |
      [$TO[] | . as $t |
        ($J | map(select((.type==$t.tag) and (($f.tag==.file) or ($f.tag==$t.file and .file==null)))) |
          sort_by(.tag) | map(
          "\(if .topComment then "\n# \(.topComment)\n" else "" end)" +
          (if $f.ftype=="brewfile" then
            "\($t.bundleCmd) \"\(.installName // .tag)\"" + "\(if .id then ", id: \(.id)" else "" end)"
          else
            "\(if $t.cmd then "\($t.cmd) " else "" end)\(if .id then "\(.id)" else "\(.installName // .tag)" end)"
          end) +
          "\(if .rightComment then " # \(.rightComment)" else "" end)\n"
        )) as $JT |
        select(($JT | length) > 0) | [
          [if $t.title then "\(title($t.title))" else "" end]
        ] + $JT] | flatten | map(select(length>0)) as $JF |
        select(($JF | length) > 0) |
          {
            "\($f.fname // .tag)": (
            [if $f.shebang then "\($f.shebang)\n" else "" end] +
            [if $f.title then "\(bigtitle($f.title))" else "" end]
            + $JF) | flatten | map(select(length>0))};

    [idt($J)] | add | to_entries' apps.json
  )


  # get filecount
  COUNT=$(jq -n --argjson FILES "$FILES" '$FILES | length')

  # build files
  for (( i = 0; i<$COUNT; i++))
  do
    FNAME=$(jq -nr --argjson FILES "$FILES" --argjson i "$i" '$FILES[$i] | .key')
    CONTENT=$(jq -nr --argjson FILES "$FILES" --argjson i "$i" '$FILES[$i] | .value | add')
    # mkdir -p "$(dirname "Dotfiles/$FNAME")" && touch "$FNAME"
    echo -e "$CONTENT" > "../$FNAME"
    # echo -e "$FNAME"
    # echo -e "$CONTENT"
  done

}
