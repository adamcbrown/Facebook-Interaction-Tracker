require 'capybara/dsl'
require 'capybara/poltergeist'
require "nokogiri"


# login
class FacebookScraper

  include Capybara::DSL
  Capybara.current_driver = :poltergeist

  attr_reader :user_name
  attr_reader :status
  attr_reader :all_names

  #doc.css(".fbxWelcomeBoxName").children.first.text -- returns name from facebook home page
  #doc.css("._8_2").children.text -- gets name from profile page
  #doc.css("._6a ._6b").children.first.attributes["href"].value --link that goes to profile page from home page

  def initialize(email, password)
    @email=email
    @password=password
    login
  end

  def login
    visit("https://www.facebook.com")
    find("#email").set(@email)
    find("#pass").set(@password)
    find("#loginbutton").click
    if Nokogiri::HTML.parse(body).css(".uiHeaderTitle").children.text =="Facebook Login"
      @status="Login Failed"
      return;
    else
      @status="Login Successful"
    end
    
    home_page = Nokogiri::HTML.parse(body)
    @user_name = home_page.css(".fbxWelcomeBoxName").children.first.text
    visit(home_page.css("._6a ._6b").children.first.attributes["href"].value)
    @profile_page = Nokogiri::HTML.parse(body)
  end

  def refresh
    visit("https://www.facebook.com")
    if Nokogiri::HTML.parse(body).at_css(".fbxWelcomeBoxName")==nil
      login
    else
      home_page = Nokogiri::HTML.parse(body)
      @user_name = home_page.css(".fbxWelcomeBoxName").children.first.text
      visit(home_page.css("._6a ._6b").children.first.attributes["href"].value)
      @profile_page = Nokogiri::HTML.parse(body)
    end
  end

  #returns an array of friend interactions (requires scrapping)
  def get_interactions(numberOfInteractions)

    text=@profile_page.css("script").children[7].text
    text=text[text.index("FriendsList"), text.length]
    text=text[text.index("[\""), text.index("}")-text.index("[\"")]
    #The string is now reduced to "[ \"ids\", \"are\", \"here\" ]"
    #The string must be parsed into an array 

    text=text.delete("\"").delete(" ").delete("[").delete("]")
    #text now only contains ids and commas

    array=text.split(",") # now an array of ids

    array=array.collect {|id| id[0, id.index("-")]}#clean away the -X at the end of the ids

    if array.length>numberOfInteractions
      return array[0, numberOfInteractions]
    end
    return array
  end

  def update_names(numberOfNames)
    refresh
    if @status=="Login Failed"
      return 
    end

    @prev_interactions=@interactions
    @interactions=get_interactions(numberOfNames)

    @prev_names=@names
    @names={}

    @interactions.each do |id|
      visit("https://www.facebook.com/profile.php?id=#{id}")
      friendPage=Nokogiri::HTML.parse(body)
      @names[id]=friendPage.css("._8_2").children.text
    end

    @all_names=@names.values
  end

  def email_body
    body=""
    if @prev_interactions 
      body+="Previously, the people that interacted the most with your account were:\n"
      for i in 0...@prev_interactions.length
        body+="#{i+1}: #{@prev_names[@prev_interactions[i]]}\n"
      end
    end

    body+="\nCurrently, the people that interacted the most with your account are:\n"
    for i in 0...@interactions.length
      body+="#{i+1}: #{@names[@interactions[i]]}\n"
    end

    if @prev_interactions
      body+="\nPeople who increased in rank are:"
      for i in 0...@interactions.length
        id=@interactions[i]
        if i>@prev_interactions.index(id)
          body+="#{@name[id]} was ranked #{@prev_interactions.index(id)+1}, and now is ranked #{i+1}\n"
        end
      end
    end

    return body
  end
end