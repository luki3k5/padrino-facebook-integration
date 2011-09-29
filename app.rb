class Facebook < Padrino::Application
  register Padrino::Helpers  
  register Padrino::Admin::AccessControl  

  configure do
    enable  :sessions
    disable :store_location
  
    set :views, File.dirname(__FILE__) + '/views'
  
    yml = YAML::load(File.open(File.dirname(__FILE__) + "/facebook_app_config.yml"))
  
    set :app_id,     yml["app_id"]
    set :app_name,   yml["app_name"]
    set :app_secret, yml["app_secret"]
    set :app_url,    yml["app_url"]  
  end 

  get '/login' do
    oauth_client = OAuth2::Client.new(settings.app_id, settings.app_url, {
        :authorize_url => 'https://www.facebook.com/dialog/oauth'
    })

    redirect oauth_client.authorize_url({
        :client_id    => settings.app_id,
        :redirect_uri => settings.app_url,
        :scope        => 'email'
    })
  end

  get '/' do
    oauth_client = OAuth2::Client.new(settings.app_id, settings.app_secret, {
        :site => 'https://graph.facebook.com',
        :token_url => '/oauth/access_token'
    })    
    
    begin
      access_token = oauth_client.get_token({
           :client_id     => settings.app_id,
           :client_secret => settings.app_secret,
           :redirect_uri  => settings.app_url,
           :code          => params[:code],
           :parse         => :query
       })
    rescue Error => e 
      puts "Error happened: #{e}"
    end      
    
    access_token.options[:mode] = :query
    access_token.options[:param_name] = :access_token
    @facebook_user = access_token.get('/me', {:parse => :json}).parsed  
    
    erb :details
  end
end