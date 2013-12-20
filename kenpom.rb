require 'mechanize'
require './lib/config.rb'
require './lib/team.rb'

module Kenpom

  BASE_URL = 'http://kenpom.com/'
  TEAM_URL = BASE_URL << 'team.php?team='

  def self.fetch_page(url)
    agent = Mechanize.new
    agent.get(BASE_URL)
    agent.follow_meta_refresh = true
    form = agent.page.forms[0]
    form.email = LOGIN_EMAIL
    form.password = LOGIN_PASSWORD
    form.submit
    agent.get(url)    
  end
end