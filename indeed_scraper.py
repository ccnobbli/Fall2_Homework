# # Scraper Version 3.0 -- Job Descriptions and locations from multiple search pages, duplications removed

from bs4 import BeautifulSoup
import urllib.request
import time
import pandas as pd
import random  # for generating random delay times, to confuse Indeed
from urllib.error import URLError, HTTPError


def printProgressBar (iteration, total, prefix = '', suffix = '', decimals = 1, length = 100, fill = '█'):
    """
    Call in a loop to create terminal progress bar
    @params:
        iteration   - Required  : current iteration (Int)
        total       - Required  : total iterations (Int)
        prefix      - Optional  : prefix string (Str)
        suffix      - Optional  : suffix string (Str)
        decimals    - Optional  : positive number of decimals in percent complete (Int)
        length      - Optional  : character length of bar (Int)
        fill        - Optional  : bar fill character (Str)
    """
    percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
    filledLength = int(length * iteration // total)
    bar = fill * filledLength + '-' * (length - filledLength)
    print('\r%s |%s| %s%% %s' % (prefix, bar, percent, suffix), end = '\r')
    # Print New Line on Complete
    if iteration == total:
        print()

# Number of search result pages to scrape (~18 posts per page)
num_pages = 100

# Job title to search for
job = "Statistician"

# URL's we need
base_url = "https://www.indeed.com/"
base_search_url = base_url + "jobs?q=" + job.replace(" ","_") + "&start="

# HTML class id used to grab the html element containing the job description
class_id = "jobsearch-JobComponent-description"


# These lists will store each job description and location as individual list elements
job_descriptions = list()
job_locations = list()
job_titles = list()

# Will hold dictionaries, each being one job posting
jobs = list()


print("Looking for {0} pages of '{1}' job postings".format(num_pages, job))
# Start Scraping here

num_done = 0


for page_num in range(0, num_pages):
    # Get links from each page of the search results, up to a specified number of pages
    time.sleep(float(random.randrange(5, 50)/100))
    # Retrieve the search results one page at a time (starting at 0, 10, 20, ....)
    while True:
        try:
            soup = BeautifulSoup(urllib.request.urlopen(base_search_url + str(page_num*10)), 'html.parser')
            break
        except (URLError, HTTPError) as e:
            time.sleep(10)
            continue
        break


    search_results = soup.find_all("div", attrs={"data-tu":""})



    for result in search_results:
        title = result.find("a", attrs={"data-tn-element":"jobTitle"})
        loc = result.find("div", attrs={"class":"sjcl"})
        if title is not None and loc is not None:
            # We got a match for a sponsored job -

            # Grab the Title of the job, the job description, and the location
            job_location = loc.find("div", attrs={'class':'location'}).get_text()

            job_title = title.get_text()

            job_link = base_url + str(title.get('href'))[1:]

            # Force Indeed to give us the job description
            while True:
                try:
                    soup_job = BeautifulSoup(urllib.request.urlopen(job_link), 'html.parser')
                    break
                except (URLError, HTTPError) as e:
                    time.sleep(5)
                    continue
                break

            job_desc = soup_job.find(class_=class_id)

            if job_location is not None and job_title is not None and job_desc is not None:
                # This job has a location, title, and description. Add it to our data
                jobs.append({"job_location": job_location,
                             "job_title": job_title,
                             "job_description": job_desc.get_text(),  # Extract job desc text here
                             "sponsored": True})

                # Update progress bar
                printProgressBar(num_done, num_pages*11, prefix='Progress:', suffix='Complete', length=50)
                num_done += 1

        else:
            # Check if this element is an organic job (not sponsored)
            title = result.find("h2", attrs={"class":"jobtitle"})
            loc = result.find("span", attrs={"class":"location"})

            if title is not None and loc is not None:
                # We have a match for an organic job, extract info

                # Grab the Title of the job
                title_element = title.find("a", attrs={"data-tn-element":"jobTitle"})
                job_title = title_element.get_text()


                # Extract Location Text
                job_location = loc.get_text()

                while True:
                    # Force Indeed to give us the job description
                    try:
                        soup_job = BeautifulSoup(urllib.request.urlopen(base_url + str(title_element.get('href'))), 'html.parser')
                        break
                    except (URLError, HTTPError) as e:
                        time.sleep(5)
                        continue
                    break

                # Extract Job Description
                job_desc = soup_job.find(class_=class_id)

                if job_location is not None and job_title is not None and job_desc is not None:
                    # This job has a location, title, and description. Add it to our data

                    jobs.append({"job_location": job_location,
                                 "job_title": job_title,
                                 "job_description": job_desc.get_text(),
                                 "sponsored": False})
                    # Update progress bar
                    printProgressBar(num_done, num_pages*11, prefix='Progress:', suffix='Complete', length=50)
                    num_done += 1

jobs_df = pd.DataFrame(jobs)
jobs_df = jobs_df[~jobs_df.job_description.duplicated()]
jobs_df.to_csv("data/" + job.replace(" ", "_") +  "_text_data.csv")

