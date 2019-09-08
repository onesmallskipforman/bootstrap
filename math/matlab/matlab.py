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
  path = sys.argv[1]

  # grab user login info
  with open(path, 'r') as file:
    usr = file.readline().replace('\n', '')
    pwd = file.readline().replace('\n', '')

  print(pwd)

  options = Options()
  options.set_preference("browser.download.folderList",2)
  options.set_preference("browser.download.dir", os.getcwd())
  options.set_preference("browser.download.manager.showWhenStarting", False)
  options.set_preference("browser.helperApps.neverAsk.saveToDisk", "application/zip")
  options.set_preference("browser.helperApps.neverAsk.openFile", "application/zip")
  options.set_preference("browser.download.manager.alertOnEXEOpen", False)
  options.set_preference("browser.download.manager.closeWhenDone", False)
  options.set_preference("browser.download.manager.focusWhenStarting", False)
  options.headless = True

  waitsec = 180

  driver = webdriver.Firefox(options = options)
  atexit.register(driver.quit) # ensure hidden driver quits when there are errors
  driver.get('https://www.mathworks.com/downloads/web_downloads/select_release')

  try:
      element = WebDriverWait(driver, waitsec).until(
          EC.presence_of_element_located((By.ID, "me"))
      )
  except:
      driver.quit()

  frame = driver.find_element_by_id("me")
  driver.switch_to.frame(frame)
  time.sleep(5) # time padding between frame switch and login

  try:
      element = WebDriverWait(driver, waitsec).until(
          EC.presence_of_element_located((By.ID, "userId"))
      )
  except:
      driver.quit()

  driver.find_element_by_id("userId").send_keys(usr)
  driver.find_element_by_id("password").send_keys(pwd)
  driver.find_element_by_id("submit").click()
  driver.switch_to.default_content()

  try:
      element = WebDriverWait(driver, waitsec).until(
          EC.presence_of_element_located((By.ID, "releaseButton"))
      )
  except:
      driver.quit()

  driver.find_element_by_id("releaseButton").click()

  # grab number of .part files
  os.chdir(os.getcwd())
  ndmg = len(glob.glob("*.dmg*"))
  npart = len(glob.glob("*.part"))

  dl = "button.btn:nth-child(2)"
  try:
      element = WebDriverWait(driver, waitsec).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, dl))
      )
  except:
      driver.quit()

  # start download
  driver.find_element_by_css_selector(dl).click()
  sys.stdout.write('Downloading Installer')
  sys.stdout.flush()
  while ( ndmg == len(glob.glob("*.dmg*")) or npart != len(glob.glob("*.part")) ): pass
  restart_line()
  sys.stdout.write('Installer Downloaded\n')
  sys.stdout.flush()
  driver.quit()


if __name__== "__main__":
  main()

