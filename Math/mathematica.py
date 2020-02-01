#!/usr/bin/env python3
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
class Mathematica():

  def __init__(self, waitsec = 180, headless = False, cache = os.getcwd()):
    self.waitsec = waitsec
    self.headless = headless
    self.cache = cache

  def __enter__(self):
        return self

  def __exit__(self, exc_type, exc_value, traceback):
    # print("\nFinishing On:", self.driver.current_url, "\n")
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
    options.set_preference("browser.helperApps.neverAsk.saveToDisk", "application/octet-stream")
    options.set_preference("browser.helperApps.neverAsk.openFile", "application/octet-stream")
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

    self.driver.get('https://account.wolfram.com/auth/sign-in')

    # enter fields and click
    self.waitFor(By.NAME, "j_username")
    self.driver.find_element_by_name("j_username").send_keys("")
    self.driver.find_element_by_name("j_password").send_keys("")

    # grab current url before signin
    current = self.driver.current_url
    self.driver.find_element_by_name("login").click()

    # wait for new url
    element = WebDriverWait(self.driver, self.waitsec).until_not(
        EC.url_to_be(current)
    )

  def authenticate(self):
    sys.stdout.write('Authenitcating....\n')
    sys.stdout.flush()
    if os.path.exists("cookies.pkl"):
      cookies = pickle.load(open("cookies.pkl", "rb"))
      self.driver.get('https://account.wolfram.com/auth/sign-in')
      for cookie in cookies:
        print(cookie)
        self.driver.add_cookie(cookie)
    else:
      self.signIn()
      cookies = self.driver.get_cookies()
      pickle.dump(cookies , open("cookies.pkl","wb"))

  def restart(self):
    sys.stdout.write('Restarting driver....\n')
    sys.stdout.flush()
    self.driver.quit()
    self.signIn()
    self.authenticate()

  def download(self):

    self.driver.get('https://user.wolfram.com/portal/myProducts.html')
    downloadspage = ".even > td:nth-child(7)"
    self.waitFor(By.CSS_SELECTOR, downloadspage)
    # .even > td:nth-child(7) > a:nth-child(1)
    self.driver.find_element_by_css_selector(downloadspage).click()

    # click download manager for mac, tr:nth-child(1)
    dl = "#downloadtable > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(4)"
    # install direct download for mac, tr:nth-child(3)
    # dl = "#downloadtable > tbody:nth-child(2) > tr:nth-child(3) > td:nth-child(4)"

    self.waitFor(By.CSS_SELECTOR, dl)
    self.driver.find_element_by_css_selector(dl).click()

    # grab number of .part files
    os.chdir(os.getcwd())
    ndmg = len(glob.glob(self.cache + "/*.dmg*"))
    npart = len(glob.glob(self.cache + "/*.part"))

    # start download window is finnicky, so wait for visibility
    try:
      self.waitFor(By.ID, "ddstart")
      WebDriverWait(self.driver, self.waitsec).until(
        EC.visibility_of(self.driver.find_element_by_id("ddstart"))
      )
      self.driver.find_element_by_id("ddstart").click()
    except:
      self.restart()
      self.download()

    sys.stdout.write('Downloading Installer...\n')
    sys.stdout.flush()
    while ( ndmg == len(glob.glob(self.cache + "/*.dmg*")) or npart != len(glob.glob(self.cache + "/*.part")) ): pass
    sys.stdout.write('Installer Downloaded...\n')
    sys.stdout.flush()


def main():
  # start = time.time()
  cache = "mathcache"
  with Mathematica(waitsec = 30, headless = True, cache = cache) as scraper:
    scraper.activate()
    scraper.signIn() # authenticate appears to not be working
    scraper.download()
  # finish = time.time()
  # print("\nTotal Time:", finish - start, "s")

  dmg = glob.glob(cache + "/*.dmg")[0]
  with zipfile.ZipFile(dmg + ".zip", 'w') as zip_ref:
    zip_ref.write(dmg, arcname = dmg)
  os.remove(dmg)

if __name__== "__main__":
  main()


# def restart_line():
#     sys.stdout.write('\r\x1b[K')
#     sys.stdout.flush()
