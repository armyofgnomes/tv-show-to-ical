require 'rubygems'
require 'icalendar'
require 'date'
require 'mechanize'

include Icalendar

cal = Calendar.new
cal.custom_property("X-WR-CALNAME", "Army of Gnomes Tv Show Feed")

#shows = File.open('showlist.yaml', 'r') #To be implemented later
shows = ['http://www.tv.com/lost/show/24313/summary.html',
        'http://www.tv.com/house/show/22374/summary.html',
        'http://www.tv.com/heroes/show/17552/summary.html',
        'http://www.tv.com/venture-brothers/show/17591/summary.html',
        'http://www.tv.com/aqua-teen-hunger-force/show/5485/summary.html',
        'http://www.tv.com/futurama/show/249/summary.html',
        'http://www.tv.com/the-riches/show/68406/summary.html',
        'http://www.tv.com/the-it-crowd-2006/show/54188/summary.html',
        'http://www.tv.com/the-boondocks/show/26812/summary.html',
        'http://www.tv.com/good-eats/show/21612/summary.html',
        'http://www.tv.com/the-office-us/show/22343/summary.html'
        ]
agent = WWW::Mechanize.new

shows.each do |url|
  begin
    webpage = agent.get(url)
    title = webpage.title.strip.scan(/(.*?) [-*TV]/).to_s
    episode = webpage.search("span.f-bold").to_s.scan(/(Next|Last|Previous) episode: (<a href=".*?">(.*?)<\/a>)/)
    nextlast = episode[0][0]
    episodeurl = episode[0][1]
    episodetitle = episode[0][2]
    airdate = webpage.search("span.f-C00").inner_html.to_s.scan(/^(\w*?)\s(\w*?)\s(\d*?), (\d*)/)
    airtime = webpage.search("span.f-333").inner_html.to_s.scan(/.*?(\d*?):(\d*?) (AM|PM)/i)
    if airtime[0][2] =~ /PM/i
      hour = airtime[0][0].to_i
      hour += 12
    end
    channel = webpage.search("span.f-333").inner_html.scan(/^\w+/)
    unless episode[0][0] == "Previous" || episode[0][0] == "Last"
      event = Event.new
      event.start = DateTime.civil(airdate[0][3].to_i, Date::MONTHNAMES.rindex(airdate[0][1]).to_i, airdate[0][2].to_i, hour, airtime[0][1].to_i)
      event.summary = title + ' - ' + episodetitle
      event.location = channel
      event.description = '"' + episodetitle + '"'
      cal.add_event(event)
    end
  rescue
  end
end
  cal_string = cal.to_ical
  puts cal_string
  File.open('rob-shows.ics', 'w') do |f|
    f.puts cal_string
  end

