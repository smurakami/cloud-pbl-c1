# SaaS Day 1
This project is for a PBL lecture course about cloud computing at the University of Tokyo.


## Procedure log
    $ rails new myapp -d mysql
    $ cd myapp
Add ruby-opencv to Gemfile

    $ echo "gem 'ruby-opencv', \"~> 0.0.10\", :require => 'opencv'" >> Gemfile
Create database and edit config/database.yml

    $ mysql -u root -p
    mysql> grant all privileges on *.* to imgproc@localhost identified by ’<SPECPASS>';
    mysql> create database image_processing default charset utf8 collate utf8_general_ci;
    $ vi config/database.yml
Edit config/initializers/secret_token.rb

    $ vi config/initializers/secret_token.rb
Generate a controller for image processing

    $ rails generate controller ImageProcessing 
Edit the controller

    $ vi app/controllers/image_processing_controller.rb
Edit the view of front page and the layout

    $ vi app/views/default.html.erb
    $ vi app/layouts/application.html.erb
Add "haarcascade_frontalface_alt.xml"

    $ cp /opt/local/share/OpenCV/haarcascades/haarcascade_frontalface_alt.xm ./haarcascade_frontalface_alt.xml
Edit the routes

    $ vi config/routes.rb
Generate SECRET_TOKEN

    $ rake secret
Run rails server

    $ RAILS_ENV=production MYAPP_DATABASE_PASSWORD="<PASSWORD>" SECRET_TOKEN="<GENERATED_SECRET_TOKEN>" bundle exec rails server

## Appendix
### Install RVM
(See: http://rvm.io/rvm/install)

    $ curl -L https://get.rvm.io | bash -s stable
    $ source ~/.rvm/scripts/rvm
    $ edit ~/.bashrc
    (add "source ~/.rvm/scripts/rvm" to "~/.bashrc")
    $ rvm requirements

    $ rvm install ruby
    $ rvm use ruby --default
    $ rvm rubygems current
    $ gem install rails
    $ gem install bundler

### Install Open CV
(See: http://docs.opencv.org/2.4/doc/tutorials/introduction/linux_install/linux_install.html)

    $ sudo apt-get install cmake build-essential

    (Download a up-to-date package, opencv-x.x.x.zip, from http://opencv.org)
    $ unzip opencv-x.x.x.zip
    $ cd opencv-x.x.x
    $ mkdir release
    $ cd release
    $ cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/opt/local ..
    $ make
    $ sudo make install
    $ gem install ruby-opencv -- --with-opencv-dir=/opt/local

