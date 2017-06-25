from lxml import html
import requests
import urllib
import smtplib
import sys

def send_email(user, pwd, recipient):

    gmail_user = user
    gmail_pwd = pwd
    FROM = user
    TO = recipient if type(recipient) is list else [recipient]
    SUBJECT =  "WMHD Radio Shows"
    TEXT = "Something went wrong with scheduling tomorrow's shows. If you do not update the schedule there will be empty airtime"

    # Prepare actual message
    message = """From: %s\nTo: %s\nSubject: %s\n\n%s
    """ % (FROM, ", ".join(TO), SUBJECT, TEXT)
    try:
        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.ehlo()
        server.starttls()
        server.login(gmail_user, gmail_pwd)
        server.sendmail(FROM, TO, message)
        server.close()
        print 'successfully sent the mail'
    except:
        print "failed to send mail"



eml= sys.argv[1]
passs = sys.argv[2]
dstemail = sys.argv[3]
print eml
print passs
print dstemail
try:
    page = urllib.urlopen("Airtime.html").read()
except:
    send_email(eml, passs, dstemail)


tree = html.fromstring(page)

shows = tree.xpath('//div[@class = "fc-event-content"]/div[@class="fc-event-title"]/text()')

filled = tree.xpath('//div[@class="ui-progressbar ui-widget ui-widget-content ui-corner-all"]/@aria-valuenow')

flag = False

print filled

for x in range(0, len(filled)):
    if filled[x] != '100':
        flag = True

print flag

if flag:
    send_email(eml, passs, dstemail)

