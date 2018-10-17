# # Scraper Version 3.0 -- Job Descriptions and locations from multiple search pages, duplications removed

from bs4 import BeautifulSoup
import urllib.request
import time
import pandas as pd
import random  # for generating random delay times, to confuse Indeed


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
num_pages = 5

# Job title to search for
job = "Data Scientist"

# URL's we need
base_url = "https://www.indeed.com/"
base_search_url = base_url + "jobs?q=Data+Scientist&start="

# HTML class id used to grab the html element containing the job description
class_id = "jobsearch-JobComponent-description"

# These lists will store each job description and location as individual list elements
job_descriptions = list()
job_locations = list()


print("Looking for {0} pages of '{1}' job postings".format(num_pages, job))
# Start Scraping here

num_done = 0
for page_num in range(0, num_pages):
    # Get links from each page of the search results, up to a specified number of pages
    
    # Retrieve the search results one page at a time (starting at 0, 10, 20, ....)
    soup = BeautifulSoup(urllib.request.urlopen(base_search_url + str(page_num*10)), 'html.parser')
    
    # "turnstileLink" elements contain one job posting - find them all!
    turnstileLinks = soup.find_all(class_="turnstileLink")
    
    # Extract the location information from each posting
    locations = soup.find_all(class_='location')
    for location in locations:
        job_locations.append(location.get_text())


    # Extract the job description for each turnstileLink on this page of search results
    for item in turnstileLinks:
        # Give us a bit of a time delay so not to anger Indeed
        time.sleep(float(random.randrange(5, 50)/100))

        if item is not None:  # Sometimes we pick up empty job postings
            # Extract the URL to the job posting page
            job_link = base_url + item.get('href')

            # Open that URL
            soup_job = BeautifulSoup(urllib.request.urlopen(job_link), 'html.parser')

            # Extract the job description text from the individual job posting
            job_panel = soup_job.find(class_=class_id)
            if job_panel is not None:  # Sometimes there is no job_panel?
                job_descriptions.append(job_panel.get_text())
                printProgressBar(num_done, num_pages*17, prefix='Progress:', suffix='Complete', length=50)
                num_done += 1
            else:
                # Add an empty element so we know something went wrong
                #job_descriptions.append("")
                pass



# Checking for same number of descriptions and locations
print("{0} Total Jobs Scraped".format(len(job_descriptions)))  # Number of job descriptions found
print("{0} Unique Jobs Scraped".format(len(list(set(job_descriptions)))))  # Number of unique job descriptions

#print(len(job_locations))  # Number of locations found

# Remove duplications by making dataframe
job_data = pd.DataFrame({"text": job_descriptions,
                         "location": job_locations})
job_data = job_data[~job_data.duplicated()]

# Save to a file
save_file = "data/text_data.csv"
job_data.to_csv(save_file)

print("Saved data to {0}".format(save_file))

# Possible Keywords to look out for:
#     R
#     Watson
#     Python
#     SQL
#     Ruby
#     SAS
#     Enterprise Miner
#     ...
