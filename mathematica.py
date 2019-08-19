#!/usr/bin/env python3

def main():
  import time, os, glob
  from selenium import webdriver
  from selenium.webdriver.firefox.options import Options
  from selenium.webdriver.common.by import By
  from selenium.webdriver.support.ui import WebDriverWait
  from selenium.webdriver.support import expected_conditions as EC

  # grab user login info
  with open('../../Backups/mathematica.txt', 'r') as file:
    usr = file.readline().replace('\n', '')
    pwd = file.readline().replace('\n', '')

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
  driver.get('https://user.wolfram.com/portal/myProducts.html')
  try:
      element = WebDriverWait(driver, waitsec).until(
          EC.presence_of_element_located((By.NAME, "j_username"))
      )
  except:
      driver.quit()

  driver.find_element_by_name("j_username").send_keys(usr)
  driver.find_element_by_name("j_password").send_keys(pwd)
  driver.find_element_by_name("login").click()
  time.sleep(2)

  try:
      element = WebDriverWait(driver, waitsec).until(
          EC.presence_of_element_located((By.XPATH, '/html/body/table/tbody/tr[3]/td/table[2]/tbody/tr[2]/td/table/tbody/tr/td[7]'))
      )
  except:
      driver.quit()

  # go to download options
  driver.find_element_by_xpath('/html/body/table/tbody/tr[3]/td/table[2]/tbody/tr[2]/td/table/tbody/tr/td[7]').click()
  time.sleep(2)

  try:
      element = WebDriverWait(driver, waitsec).until(
          EC.presence_of_element_located((By.XPATH, '/html/body/table/tbody/tr[3]/td/div[2]/table[3]/tbody/tr[2]/td/table/tbody/tr[2]/td/div/table/tbody/tr[1]/td[4]'))
      )
  except:
      driver.quit()

  # pick mac download manager   /html/body/table/tbody/tr[3]/td/div[2]/table[3]/tbody/tr[2]/td/table/tbody/tr[2]/td/div/table/tbody/tr[1]/td[4]/span/div/a[2]/span
  driver.find_element_by_xpath('/html/body/table/tbody/tr[3]/td/div[2]/table[3]/tbody/tr[2]/td/table/tbody/tr[2]/td/div/table/tbody/tr[1]/td[4]').click()
  time.sleep(2)

  # grab number of .part files
  os.chdir(os.getcwd())
  ndmg = len(glob.glob("*.dmg*"))
  npart = len(glob.glob("*.part"))

  try:
      element = WebDriverWait(driver, waitsec).until(
          EC.presence_of_element_located((By.XPATH, '/html/body/div[5]/div[2]/table[3]/tbody/tr/td[1]/div'))
      )
  except:
      driver.quit()

  time.sleep(10)

  # start download  
  print("starting download")
  driver.find_element_by_xpath('/html/body/div[5]/div[2]/table[3]/tbody/tr/td[1]').click()
  while ( ndmg == len(glob.glob("*.dmg*")) or npart != len(glob.glob("*.part")) ): pass
  print("download complete")
  driver.quit()

if __name__== "__main__":
  main()



