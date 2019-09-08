#!/usr/bin/env python3

import time, os, glob, sys, atexit
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

def restart_line():
    sys.stdout.write('\r\x1b[K')
    sys.stdout.flush()

def main():

  # login file path
  print(sys.argv[1])
  path = sys.argv[1]

  # grab user login info
  with open(path, 'r') as file:
    usr = file.readline().replace('\n', '')
    pwd = file.readline().replace('\n', '')

  print(usr)

  options = Options()
  options.set_preference("browser.download.folderList",2)
  options.set_preference("browser.download.dir", os.getcwd())
  options.set_preference("browser.download.manager.showWhenStarting", False)
  options.set_preference("browser.helperApps.neverAsk.saveToDisk", "application/octet-stream")
  options.set_preference("browser.helperApps.neverAsk.openFile", "application/octet-stream")
  options.set_preference("browser.download.manager.alertOnEXEOpen", False)
  options.set_preference("browser.download.manager.closeWhenDone", False)
  options.set_preference("browser.download.manager.focusWhenStarting", False)
  options.headless = True

  waitsec = 180

  driver = webdriver.Firefox(options = options)
  atexit.register(driver.quit) # ensure hidden driver quits when there are errors
  driver.get('https://user.wolfram.com/portal/download.html?exec=11088&lic=31854707&lpid=4148215')

  try:
      element = WebDriverWait(driver, waitsec).until(
          EC.presence_of_element_located((By.NAME, "j_username"))
      )
  except:
      driver.quit()

  # grab number of .part files
  os.chdir(os.getcwd())
  ndmg = len(glob.glob("*.dmg*"))
  npart = len(glob.glob("*.part"))

  # sign in, thus starting the download
  driver.find_element_by_name("j_username").send_keys(usr)
  driver.find_element_by_name("j_password").send_keys(pwd)
  driver.find_element_by_name("login").click()

  # start download
  sys.stdout.write('Downloading Installer')
  sys.stdout.flush()
  while ( ndmg == len(glob.glob("*.dmg*")) or npart != len(glob.glob("*.part")) ): pass
  restart_line()
  sys.stdout.write('Installer Downloaded\n')
  sys.stdout.flush()
  driver.quit()

if __name__== "__main__":
  main()



