require 'watir'
require 'headless'
puts "starting"
#to run, call with command line args for num of days to advance, usrname, password


#hash of shows, listed by hour => smart block search terms
shows = {2 => "Smart Block Electronic", 4 => "Smart Block Metal", 6 => "Smart Block Classical",
         8 => "Smart Block Jazz", 10 => "2hrSmartBlockEverything", 12 => "1hrSmartBlockEverything",
         13 => "Smart Block Rock", 15 => "Smart Block Country", 17 => "Smart Block Pop",
         19 => "4hrAltIndie", 20 => "3hrAltIndie", 21 => "2hrAltIndie", 22 => "1hrAltIndie",  23 => "Smart Block Rhythm"}

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
sleep(1)
#go to calendar
browser.link(:text, "Calendar").click


sleep(1)
#click on day
begin
browser.span(:class, "fc-button fc-button-agendaDay ui-state-default ui-corner-left ui-corner-right ui-state-active").click
rescue Watir::Exception::UnknownObjectException
  browser.span(:class, "fc-button fc-button-agendaDay ui-state-default ui-corner-left ui-corner-right").click
end


#click next day
day_advance.times do
browser.span(:class, "fc-button fc-button-next ui-state-default ui-corner-left ui-corner-right").click
end
#zoom out and sleep
browser.element(:xpath, "//select[@class = 'schedule_change_slots input_select']").option(:value, "60").click
sleep(1)


#create element to select shows
#get day
dow = browser.element(:xpath, "//span[@class = 'fc-header-title']/h2").text
dow = dow[0..2]
dow.downcase!

#concatenate with rest of element name
table_element = "fc-" + dow + " fc-col0 ui-widget-content"
#sometimes has fc-last
table_element_2 = table_element + " fc-last"

clicked = false

#iterate through shows table
shows.each do |key, val|

#click on show
  begin
    browser.driver.action.move_to(browser.td(:class, table_element).wd, 10,
                                  (21*key) + 2).click.perform
  rescue Watir::Exception::TableDataCell
    browser.driver.action.move_to(browser.td(:class, table_element_2).wd, 10,
                                  (21*key) + 2).click.perform
  end
  sleep(1)


  #click to add content
  browser.element(:xpath, "//span[text() = 'Add / Remove Content']").click
  sleep(1)


  #add WMHD tagline
  #click search box
  browser.element(:xpath, "//div[@class = 'dataTables_filter']/label/input").click
  sleep(1)
  #send search terms
  browser.element(:xpath, "//div[@class = 'dataTables_filter']/label/input").send_keys "WMHDRadio1"
  #click checkbox
  sleep(1)
  if !clicked
    browser.element(:xpath, "//td[@class = 'library_checkbox']/input[@type = 'checkbox']").click
    clicked = true
  end
  #attempt to add to show. if failed is because show is full, will continue
  begin
    browser.button(:id, "library-plus").click
  rescue Watir::Exception::ObjectDisabledException
    #continue
  end
  sleep(1)

  browser.element(:xpath, "//div[@class = 'dataTables_filter']/label/input").to_subtype.clear

  #search for smart block
  #select smart block type
  browser.element(:xpath, "//select[@name = 'library_display_type']").option(:value, "3").click
  sleep(1)
  #click on search box and then send
  browser.element(:xpath, "//div[@class = 'dataTables_filter']/label/input").click
  puts "clicked"
  browser.element(:xpath, "//div[@class = 'dataTables_filter']/label/input").send_keys val
  sleep(1)

  #click the block
  browser.element(:xpath, "//td[@class = 'library_checkbox']/input[@type = 'checkbox']").click

  #attempt to add to show. if failed show is full
  begin
    browser.button(:id, "library-plus").click
  rescue Watir::Exception::ObjectDisabledException
    #continue
  end
  sleep(1)

  #unclick box
  browser.element(:xpath, "//td[@class = 'library_checkbox']/input[@type = 'checkbox']").click

  #exit out
  browser.element(:xpath, "//div[@class = 'ui-dialog-buttonset']/button").click
sleep(2)
end



sleep(5)

File.open('Airtime.html', 'w') {|f| f.write browser.html }


#close browser and destroy headless
browser.close
headless.destroy
