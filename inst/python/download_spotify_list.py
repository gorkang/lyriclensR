#!/usr/bin/python 

# TODO: CLEANUP UNNEEDED DEPENDENCIES!

# Installation instructions!
# reticulate::py_install("undetected_chromedriver", method = "virtualenv")
## reticulate::py_install("distutils", method = "virtualenv") # distutils not yet ready for python3.12 (?)
## Installing setuptools AND adding import setuptools.dist to the .py file works?
# reticulate::py_install("setuptools", method = "virtualenv") # setuptools includes distutils



import setuptools.dist
import undetected_chromedriver as uc # the driver
# from seleniumbase import Driver  # the driver
from selenium.webdriver.common.by import By # to find various items on the page
from selenium.webdriver.chrome.options import Options # to have devtools open
import re
import time # for sleeps
import random # so sleeps are varied
from datetime import datetime
from bs4 import BeautifulSoup
import requests
  
# https://github.com/ultrafunkamsterdam/undetected-chromedriver
# Install from Terminal in RStudio
# pip install undetected-chromedriver

def save_page(driver, WEB, page = 1):

  # Save page  
  print("Saving page " + str(page))
  
  # If it's the first page, wait for human intervention as we might find a catpcha
  # if page == 1:
  #   input("Press Enter to continue...")


  # File name
  part_URL =  re.sub("/en/|/", "_", re.sub("https://open.spotify.com/playlist/", "", WEB))
  file_name = "outputs/www/" + datetime.now().strftime('%Y-%m-%d %H:%M:%S') + " " + part_URL + str(page) + ".html"
  
  # Write html file
  with open(file_name, "w", encoding='utf-8') as f:
    f.write(driver.page_source)
    time.sleep(1)
  


# Create driver instance (open browser)
def createDriverInstance():
    print("Opening browser")
    options = Options()
    # options.add_argument('--auto-open-devtools-for-tabs')
    options.headless = False
    driver = uc.Chrome(options=options)
    # driver = Driver(uc=True)
    time.sleep(2)
    return driver


def download_spotify_list(WEB):
  # WEB = "https://open.spotify.com/playlist/37i9dQZEVXbNFJfN1Vw8d9"
  # WEB = "https://open.spotify.com/playlist/37i9dQZEVXbMDoHDwVN2tF"
  # WEB = "https://open.spotify.com/playlist/6UeSakyzhiEt4NB3UAd6NQ"
  from selenium import webdriver
  from selenium.common.exceptions import TimeoutException
  from selenium.webdriver.support.ui import WebDriverWait
  from selenium.webdriver.support import expected_conditions as EC
  from selenium.webdriver.common.by import By
  from selenium.webdriver.common.keys import Keys

  
  # Open browser()
  driver = createDriverInstance()
  
  # Open web
  driver.get(WEB)

  # Wait 5 secs or until element is present
  timeout = 5
  element_present = EC.presence_of_element_located((By.XPATH, '//*[@id="onetrust-accept-btn-handler"]'))
  WebDriverWait(driver, timeout).until(element_present)

  # Accept cookies message
  cookies = driver.find_element(By.XPATH, '//*[@id="onetrust-accept-btn-handler"]')
  cookies.click()

  # Select compact mode so the E (in explicit songs) wont bleed into the Artist column
  LIST = driver.find_element(By.XPATH, '//*[@id="main-view"]/div/div[2]/div[1]/div/main/section/div[2]/div[2]/div[1]/div/div/div[2]/button')
  LIST.click()
  # LIST.send_keys(" and some", Keys.ARROW_UP)
  
  # This changes often, and send keys does not work :(
  # LIST2 = driver.find_element(By.XPATH, '//*[@id="sortboxlist-0580bc05-0cd7-48cb-a811-b19b62f2569d"]/li[2]/button/span[1]')
  LIST2 = driver.find_element(By.XPATH, '//button[@class="niXChlbt7kxslMUdfwu9"]').click()
  
  # Zoom out so all the songs are visible (for some reason, the non-visible songs cannot be accesed)
  driver.execute_script("document.body.style.zoom='1%'")

  # OLD way
  # # Scroll down to make sure we download the full list of songs
  # LIST.send_keys(Keys.PAGE_DOWN)
  # LIST.send_keys(Keys.PAGE_DOWN)
  # LIST.send_keys(Keys.PAGE_DOWN)
  # LIST.send_keys(Keys.PAGE_DOWN)  
  # LIST.send_keys(Keys.PAGE_DOWN)
  # LIST.send_keys(Keys.PAGE_DOWN)
  # LIST.send_keys(Keys.PAGE_DOWN)
  
  # Save web
  XX = save_page(driver, WEB, 1)
  
  
  driver.quit()

