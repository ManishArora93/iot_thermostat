require 'rails_helper'
RSpec.describe API::V1::Reading do

  describe "Readings Scope" do
    before(:all) do
      @thermostat = build(:thermostat)
      @thermostat.save!
    end

    context 'POST /api/v1/readings/add_reading' do
      it 'creates readings ' do
        data = { thermostat_id: @thermostat.thermostat_token, temperature: 20, battery_charge: 80, humidity: 15, reading_id: 1 }
        post '/api/v1/readings/add_reading', params: data, headers: { "Authorisation-Token" => @thermostat.thermostat_token }
        expect(response.status).to eq 201
        expect(JSON.parse(response.body)).to have_key('reading_id')
      end
    end

    context 'GET /api/v1/reading/1' do
      it 'creates many statuses' do
        get '/api/v1/readings/1', headers: { "Authorisation-Token" => @thermostat.thermostat_token }
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to have_key('reading')
      end
    end

    context 'GET /api/v1/thermostats/1' do
      it 'Thermostat stats' do
        get '/api/v1/thermostats/1', headers: { "Authorisation-Token" => @thermostat.thermostat_token }
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to have_key('stats')
      end
    end
  end
end
