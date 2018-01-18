### USING THIS SCRIPT ###

You'll need the following in order to execute this script:

* Ruby - it's installed by default on Mac OSX, you'll need to install it on Windows (https://rubyinstaller.org/).  I don't know about Linux (https://www.ruby-lang.org/en/documentation/installation/)
* A Google Sheets account - if you have a Gmail account, you have this.
* You'll need to already have the sample spreadsheet that I've depicted in this YouTube video (https://www.youtube.com/watch?v=HGZjxcfJnKk) The sheet is linked in the comments.  
* Some Ruby Gems - once you have Ruby installed, you can `gem install GEM_NAME` from your shell and it will install the gem for you.  Do this from the same directory where you have saved this script.  You can find the gems listed at the top of the get_mutual_fund_data.rb file where it says `require $GEM` - there are four as of this writing, you don't really need pry.
* Make the script executable if this matters in your environment.  You should be able to type `ruby get_mutual_fund_data.rb` from your shell (as long as you're inside the directory where the script lives) and it will execute just fine.  If you have permissions setup where this is restricted, you may need to chmod +x the file.  
* You need to get THE SPREADSHEET ID from your version of the spreadsheet, and paste it on line 195 of the get_mutual_fund_data.rb file where it says YOUR_GOOGLE_SPREADSHEET_ID_HERE.  If you don't do this - surprise!  It's not going to work.  

Once you have all these tasks completed, you just type `ruby get_mutual_fund_data.rb` from within the directory where you've saved this script, and it will automatically update the tab labeled "Funds" in your spreadsheet based on whatever tickers you have listed there.  

When you first execute the script, your default browser will open and you'll be directed to a Google page asking for permission to access your account - this process creates a file called config.json in the same directory as this script which will allow the script to update your spreadsheet moving forward.  You need this file, and it needs to have the credentials which are automatically written in order to function.  Don't mess with it.  This repo doesn't have that file, because MY version of the file accesses my Google account.  Yours will get created by the google_drive gem.
