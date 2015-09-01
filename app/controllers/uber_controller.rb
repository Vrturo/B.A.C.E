  require 'debugger'
  require 'JSON'


get '/uberoauth' do

  response = HTTParty.post('https://login.uber.com/oauth/token',
    {
      body: {
        client_secret: ENV['UBER_CLIENT_SECRET'],
        client_id: ENV['UBER_CLIENT_ID'],
        code: params[:code],
        grant_type: "authorization_code",
        redirect_uri: "http://localhost:9393/uberoauth"
      }
    }
  )
  body = JSON.parse(response.body)
  @access_token = body["access_token"]

  HEADER = {
    "Authorization" => "Bearer #{@access_token}"
  }

  @profile = HTTParty.get("https://api.uber.com/v1/me",
                  headers: HEADER,
                  data:{scope: "profile"})


  @user = Uberuser.new(
          first_name: @profile["first_name"],
          last_name: @profile["last_name"],
          email: @profile["email"])
  if @user.valid?
    session[:user_id] = @profile["uuid"]
    erb :"users/index"
  else
    p @errors = @user.errors.messages
    erb :"users/index"
  end
end

