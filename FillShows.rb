require 'watir'
require 'headless'
puts "starting"
#to run, call with command line args for num of days to advance, usrname, password

shows = ["RapHipHop", "RapHipHop", "Metal", "Metal", "Everything", "Everything", "Classical", "Classical", "Jazz", "Jazz", "Pop", "Rock", "Everything", "Everything", "Country", "Country", "Electronic", "Electronic", "Pop", "Pop", "Rock", "Rock", "Alt", "Alt"]
#shows = ["1hrRhythmSmartBlock", "1hrRhythmSmartBlock", "1hrElectronicSmartBlock",  "1hrElectronicSmartBlock", "1hrMetalSmartBlock", "1hrMetalSmartBlock", "1hrClassicalSmartBlock", "1hrClassicalSmartBlock", "1hrJazzSmartBlock", "1hrJazzSmartBlock", "1hrSmartBlockEverything", "1hrSmartBlockEverything", "1hrSmartBlockEverything", "1hrRockSmartBlock", "1hrRockSmartBlock", "1hrCountrySmartBlock", "1hrCountrySmartBlock", "1hrSmartBlockPop", "1hrSmartBlockPop", "1hrAltIndie",  "1hrAltIndie", "1hrAltIndie", "1hrAltIndie", "1hrRhythmSmartBlock"]

#take arg for what day in advance to fill
day_advance = ARGV[0].to_i
usrnm = ARGV[1]
pswd = ARGV[2]


#open the browser, start headless
Watir.relaxed_locate = false
headless = Headless.new
headless.start
browser = Watir::Browser.new :chrome
#go to website and login
browser.goto 'https://dj.wmhdradio.org/login'
browser.text_field(:name, "username").set(usrnm)
browser.text_field(:name, "password").set(pswd)
browser.button(:name, "submit").click


#go to calendar
cal = browser.link(:text, "Calendar")
cal.wait_until_present
cal.click


#click on day
begin
  nextDay = browser.span(:class, "fc-button fc-button-agendaDay ui-state-default ui-corner-left ui-corner-right ui-state-active")
  nextDay.wait_until_present(timeout: 1)
  nextDay.click
rescue Watir::Exception::UnknownObjectException
  browser.span(:class, "fc-button fc-button-agendaDay ui-state-default ui-corner-left ui-corner-right").click
end


#click next day
day_advance.times do
  browser.span(:class, "fc-button fc-button-next ui-state-default ui-corner-left ui-corner-right").click
end
#zoom out and sleep
browser.element(:xpath, "//select[@class = 'schedule_change_slots input_select']").option(:value, "60").click


#create element to select shows
#get day
day = browser.element(:xpath, "//span[@class = 'fc-header-title']/h2")
day.wait_until_present
dow = day.text
dow = dow[0..2]
dow.downcase!

#concatenate with rest of element name
table_element = "fc-" + dow + " fc-col0 ui-widget-content"
#sometimes has fc-last
table_element_2 = table_element + " fc-last"

clicked = false

#iterate through shows table
key = 0
shows.each do |val|

#click on show
  begin
    browser.td(:class, table_element).wait_until_present(timeout: 1)
    browser.driver.action.move_to(browser.td(:class, table_element).wd, 10,
                                  (21*key) + 2).click.perform
  rescue Watir::Exception::TableDataCell
    browser.td(:class, table_element_2).wait_until_present
    browser.driver.action.move_to(browser.td(:class, table_element_2).wd, 10,
                                  (21*key) + 2).click.perform
  end


  #click to add content
  ad = browser.element(:xpath, "//span[text() = 'Add / Remove Content']")
  ad.wait_until_present
  ad.click


  #add WMHD tagline
  #click search box
  box = browser.element(:xpath, "//div[@class = 'dataTables_filter']/label/input")
  box.wait_until_present
  box.click

  #send search terms
  search = browser.element(:xpath, "//div[@class = 'dataTables_filter']/label/input")
  search.wait_until_present
  search.send_keys "WMHDRadio1"

  #click checkbox
  sleep(1)
  if !clicked
    ckbox = browser.element(:xpath, "//td[@class = 'library_checkbox']/input[@type = 'checkbox']")
    ckbox.wait_until_present
    ckbox.click
    clicked = true
  end

  #attempt to add to show. if failed is because show is full, will continue
  begin
    calBtn = browser.button(:id, "library-plus")
    calBtn.wait_until_present
    calBtn.click
  rescue Watir::Exception::ObjectDisabledException
    #continue
  end

  browser.element(:xpath, "//div[@class = 'dataTables_filter']/label/input").to_subtype.clear
  #search.to_subtype.clear

  #search for smart block
  #select smart block type
  browser.element(:xpath, "//select[@name = 'library_display_type']").option(:value, "3").click
  sleep(1)

  #click on search box and then send
  bx = browser.element(:xpath, "//div[@class = 'dataTables_filter']/label/input")
  bx.wait_until_present
  bx.click
  puts "clicked"
  valueToSend = "2hr" + val
  browser.element(:xpath, "//div[@class = 'dataTables_filter']/label/input").send_keys valueToSend
  sleep(1)

  #click the block
  block = browser.element(:xpath, "//td[@class = 'library_checkbox']/input[@type = 'checkbox']")
  block.wait_until_present
  block.click

  #attempt to add to show. if failed show is full
  begin
    addBtn = browser.button(:id, "library-plus")
    addBtn.wait_until_present
    addBtn.click
  rescue Watir::Exception::ObjectDisabledException
    #continue
  end
  sleep(1)

  #unclick box
  unblock = browser.element(:xpath, "//td[@class = 'library_checkbox']/input[@type = 'checkbox']")
  unblock.wait_until_present
  unblock.click

  #exit out
  ext = browser.element(:xpath, "//div[@class = 'ui-dialog-buttonset']/button")
  ext.wait_until_present
  ext.click
  key = key + 1
end

sleep(3)

File.open('Scripts/WMHD-WebScripts/Airtime.html', 'w') {|f| f.write browser.html }


#close browser and destroy headless
browser.close
headless.destroy
