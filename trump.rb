require 'twitter'
# for trumptracker data.json API
require 'json'
require 'open-uri'

while true
    begin
        config = {
            consumer_key:        '',
            consumer_secret:     '',
            access_token:        '',
            access_token_secret: ''
        }

        restClient = Twitter::REST::Client.new(config)
        streamingClient = Twitter::Streaming::Client.new(config)

        url = JSON.load(open("https://raw.githubusercontent.com/TrumpTracker/trumptracker.github.io/master/_data/data.json"))

        data = JSON.parse(url.to_json)

        # parse json API to select promises # for Achieved, Broken, and Not Started
        achievedInt     =   data['promises'].select { |h| h['status'] == 'Achieved' }.count
        brokenInt       =   data['promises'].select { |h| h['status'] == 'Broken' }.count
        notStartedInt   =   data['promises'].select { |h| h['status'] == 'Not started' }.count

        # Calculate 'Days In Office' from Inauguration Date
        todaysDate = DateTime.now.to_date
        inaugrationDate = Date.parse("2017-01-20")
        daysInOffice = (todaysDate-inaugrationDate).to_i

        # 25073877 is permanent user id for President Trump
        streamingClient.filter(follow: '25073877') do |tweet|
            if tweet.is_a?(Twitter::Tweet)
                puts tweet.text
                puts tweet.created_at
                puts "_________________________"
                restClient.update("@realDonaldTrump achieved #{achievedInt} promises, broke #{brokenInt}, and has not started #{notStartedInt} during his #{daysInOffice} days in office. More on https://trumptracker.github.io/")
            end
        end
    end
end
