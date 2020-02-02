#!/usr/bin/env python3

import time, os, glob, sys, atexit
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import subprocess
import pickle
import zipfile
class Matlab():

  def __init__(self, waitsec=180, headless=False, cache=os.getcwd(), user, pwd):
    self.waitsec = waitsec
    self.headless = headless
    self.user = user
    self.pwd = pwd
    self.cache = cache

  def __enter__(self):
        return self

  def __exit__(self, exc_type, exc_value, traceback):
    sys.stdout.write('Closing Driver....\n')
    sys.stdout.flush()
    if self.headless == True:
      self.driver.quit()

  def activate(self):
    sys.stdout.write('Activating Driver....\n')
    sys.stdout.flush()

    options = Options()
    options.set_preference("browser.download.folderList",2)
    options.set_preference("browser.download.dir", os.path.abspath(self.cache))
    options.set_preference("browser.download.manager.showWhenStarting", False)
    options.set_preference("browser.helperApps.neverAsk.saveToDisk", "application/zip")
    options.set_preference("browser.helperApps.neverAsk.openFile", "application/zip")
    options.set_preference("browser.download.manager.alertOnEXEOpen", False)
    options.set_preference("browser.download.manager.closeWhenDone", False)
    options.set_preference("browser.download.manager.focusWhenStarting", False)
    options.headless = self.headless

    self.driver = webdriver.Firefox(options = options, service_log_path = '/dev/null')

    if not os.path.exists(self.cache): os.mkdir(self.cache)

  def waitFor(self, infoType, info):
    element = WebDriverWait(self.driver, self.waitsec).until(
        EC.presence_of_element_located((infoType, info))
    )

  def signIn(self):
    sys.stdout.write('Signing In....\n')
    sys.stdout.flush()

    self.driver.get('https://www.mathworks.com/login')

    # wait for frame and switch to it
    # WebDriverWait(self.driver, self.waitsec).until(
    #   EC.frame_to_be_available_and_switch_to_it((By.CLASS_NAME,'embeddedForm'))
    # )
    self.waitFor(By.CLASS_NAME, "embeddedForm")
    frame = self.driver.find_element_by_class_name("embeddedForm")
    self.driver.switch_to.frame(frame)

    # this website's login fields are finnicky, so wait for visibility
    self.waitFor(By.ID, "userId")
    WebDriverWait(self.driver, self.waitsec).until(
      EC.visibility_of(self.driver.find_element_by_id("userId"))
    )

    self.driver.find_element_by_id("userId").send_keys(self.user)
    self.driver.find_element_by_id("password").send_keys(self.pwd)

    # grab current url before signin
    current = self.driver.current_url
    self.driver.find_element_by_id("submit").click()
    self.driver.switch_to.default_content()

    # wait for new url
    element = WebDriverWait(self.driver, self.waitsec).until_not(
        EC.url_to_be(current)
    )

  def authenticate(self):
    sys.stdout.write('Authenitcating....\n')
    sys.stdout.flush()
    if os.path.exists(self.cache + "/cookies.pkl"):
      cookies = pickle.load(open(self.cache + "/cookies.pkl", "rb"))
      self.driver.get('https://www.mathworks.com/login')
      for cookie in cookies: self.driver.add_cookie(cookie)
    else:
      self.signIn()
      cookies = self.driver.get_cookies()
      pickle.dump(cookies , open(self.cache + "/cookies.pkl","wb"))

  def restart(self):
    sys.stdout.write('Restarting driver....\n')
    sys.stdout.flush()
    self.driver.quit()
    self.activate()
    self.authenticate()

  def download(self, version='latest'):

    if version == 'latest':
      self.driver.get('https://www.mathworks.com/downloads/web_downloads')
      self.waitFor(By.ID, "download_btn")
      self.driver.find_element_by_id("download_btn").click()
    else:
      self.driver.get('https://www.mathworks.com/downloads/web_downloads/download_release?release=' + version)

    # grab number of .part files
    os.chdir(os.getcwd())
    ndmg = len(glob.glob(self.cache + "/*.dmg*"))
    npart = len(glob.glob(self.cache + "/*.part"))

    # install for mac (2)
    # TODO: make struct for mac, linux, maybe windows
    dl = "button.btn:nth-child(2)"
    self.waitFor(By.CSS_SELECTOR, dl)

    # start download
    self.driver.find_element_by_css_selector(dl).click()
    sys.stdout.write('Downloading Installer...\n')
    sys.stdout.flush()
    while ( ndmg == len(glob.glob(self.cache + "/*.dmg*")) or npart != len(glob.glob(self.cache + "/*.part")) ): pass
    sys.stdout.write('Installer Downloaded...\n')
    sys.stdout.flush()

def main():
  args = sys.argv[1:]

  # start = time.time()
  with Matlab(user = args[0], pwd = args[1], cache = args[2], waitsec = 30, headless = True) as scraper:
    scraper.activate()
    scraper.authenticate()
    scraper.download(args[3])
  # finish = time.time()
  # print("\nTotal Time:", finish - start, "s")

if __name__== "__main__":
  main()
