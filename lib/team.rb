module Kenpom

  class Team
    attr_reader :name, :nickname, :rank, :wins, :losses, :coach_name, :coach_url, :conference_name,
      :conference_url, :schedule, :player_stats

    def self.fetch_team(name, year)
      Kenpom.fetch_page("#{TEAM_URL}#{name}&y=#{year}")
    end

    def self.parse_nickname(page)
      nil
    end

    def self.parse_rank(page)
      page.at('#title-container h5 .rank:nth-child(1)').text
    end

    def self.parse_wins(page)
      page.at('#title-container h5 .rank:nth-child(2)').text[/\((.*?)\-/, 1]
    end

    def self.parse_losses(page)
      page.at('#title-container h5 .rank:nth-child(2)').text[/\-(.*?)\)/, 1]
    end

    def self.parse_coach_name(page)
      page.at('#title-container .update a').text
    end

    def self.parse_coach_url(page)
      page.at('#title-container .update a')['href']
    end

    def self.parse_conference_name(page)
      page.at('#title-container .otherinfo a').text
    end

    def self.parse_conference_url(page)
      page.at('#title-container .otherinfo a')['href']
    end

    def self.parse_schedule(page)
      schedule, schedule_rows = [], []

      page.search('#schedule-table tbody:nth-child(2) tr').each do |tr|
        schedule_rows << tr
      end
      schedule_rows = schedule_rows[0..-6]

      schedule_rows.each do |row|
        future_game = row.attributes['class'].value == 'un'

        schedule << {
          future_game: future_game,
          date: row.children[0].children[0].attributes['href'].value[15..-1],
          opponent: row.children[4].children[0].text,
          team_rank: row.children[2].text.to_i,
          opponent_rank: row.children[3].text.to_i,
          result: row.children[5].text[0],
          score: row.children[5].text[3..-1].to_i,
          tempo: row.children[6].text.to_i,
          overtime: future_game ? "" : row.children[7].text.gsub('&nbsp', ''),
          confidence: future_game ? row.children[7].text.to_f : "",
          location: future_game ? row.children[8].text : row.children[9].text,
          wins_after: future_game ? "" : row.children[11].text.split('-')[0].to_i,
          losses_after: future_game ? "" : row.children[11].text.split('-')[1].to_i,
          conference_game: nil
        }
      end

      schedule
    end

    def self.parse_player_stats(page)
      players, player_rows = [], []

      page.search('#player-table tbody tr:not(.label)').each do |tr|
        player_rows << tr
      end

      player_rows.each do |row|
        players << {
          name: row.children[1].children[0].text,
          url: row.children[1].children[0].attributes['href'].value,
          starter: row.attributes['class'].value == 'starter',
          jersey: row.children[0].children[0].text.to_i,
          height: row.children[2].text,
          weight: row.children[3].text.to_i,
          year: row.children[4].text,
          games: row.children[5].text.to_i,
          min_pct: row.children[7].text.to_f,
          off_rtg: row.children[8].text.to_f,
          poss_pct: row.children[9].text.to_f,
          shots_pct: row.children[10].text.to_f,
          efg_pct: row.children[11].text.to_f,
          ts_pct: row.children[12].text.to_f,
          or_pct: row.children[13].text.to_f,
          dr_pct: row.children[14].text.to_f,
          ast_rate: row.children[15].text.to_f,
          to_rate: row.children[16].text.to_f,
          blk_pct: row.children[17].text.to_f,
          stl_pct: row.children[18].text.to_f,
          fc_per_40: row.children[19].text.to_f,
          fd_per_40: row.children[20].text.to_f,
          ft_rate: row.children[21].text.to_f,
          ftm: row.children[22].text.split('-')[0].to_i,
          fta: row.children[22].text.split('-')[1].to_i,
          ft_pct: row.children[23].text.to_f,
          twos_made: row.children[24].text.split('-')[0].to_i,
          twos_att: row.children[24].text.split('-')[1].to_i,
          twos_pct: row.children[25].text.to_f,
          threes_made: row.children[26].text.split('-')[0].to_i,
          threes_att: row.children[26].text.split('-')[1].to_i,
          threes_pct: row.children[27].text.to_f
        }
      end

      players
    end
    
    def initialize(name, year = 2014)
      page = Team.fetch_team(name, year)

      @name            = name
      @year            = year.to_s
      @nickname        = Team.parse_nickname page
      @rank            = Team.parse_rank page
      @wins            = Team.parse_wins page
      @losses          = Team.parse_losses page
      @coach_name      = Team.parse_coach_name page
      @coach_url       = Team.parse_coach_url page
      @conference_name = Team.parse_conference_name page
      @conference_url  = Team.parse_conference_url page
      @schedule        = Team.parse_schedule page
      @player_stats    = Team.parse_player_stats page      
    end

    def find_player_by_name(name)
      self.player_stats.find { |p| p[:name] == name }
    end
    alias_method :player, :find_player_by_name

    def sort_players(category)
      sorted = self.player_stats.sort_by { |k| k[category] }.reverse
    end
  end
end