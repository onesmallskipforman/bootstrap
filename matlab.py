#!/usr/bin/env python3

def main(): 
  import time, os, glob
  from selenium import webdriver
  from selenium.webdriver.firefox.options import Options
  from selenium.webdriver.common.by import By
  from selenium.webdriver.support.ui import WebDriverWait
  from selenium.webdriver.support import expected_conditions as EC

  # grab user login info
  with open('../../Backups/matlab.txt', 'r') as file:
    usr = file.readline().replace('\n', '')
    pwd = file.readline().replace('\n', '')

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
  driver.get('https://www.mathworks.com/downloads/web_downloads/select_release')

  try:
      element = WebDriverWait(driver, waitsec).until(
          EC.presence_of_element_located((By.ID, "me"))
      )
  except:
      driver.quit()

  frame = driver.find_element_by_id("me")
  driver.switch_to.frame(frame)
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

  try:
      element = WebDriverWait(driver, waitsec).until(
          EC.presence_of_element_located((By.XPATH, "/html/body/div[5]/div/div/div/div[2]/div[1]/div[1]/div[2]/div/div/button[2]"))
      )
  except:
      driver.quit()

  # start download
  driver.find_element_by_xpath("/html/body/div[5]/div/div/div/div[2]/div[1]/div[1]/div[2]/div/div/button[2]").click()
  print("starting download")
  while ( ndmg == len(glob.glob("*.dmg*")) or npart != len(glob.glob("*.part")) ): pass
  print("download complete")
  driver.quit()


if __name__== "__main__":
  main()

