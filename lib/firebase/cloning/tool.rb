require "firebase/cloning/tool/version"
require 'capybara'
require 'capybara/dsl'
require 'pry'
require 'io/console'

module Firebase
  module Cloning
    module Tool

      def self.wait_until_text_is_present(text, wait=5)
        wait.times do
          break     if Capybara.has_text? text
          puts 'Waiting for text: ' + text + '...'
          sleep 1
        end
      end

      def self.wait_until_text_is_not_present(text, wait=5)
        wait.times do
          break     if Capybara.has_no_text? text
          puts 'Waiting until text dissapear: ' + text + '...'
          sleep 1
        end
      end

      def self.do_login(email, password)
        puts 'Trying sign in for ' + email + '...'
        Capybara.fill_in('Email', with: email)
        Capybara.find('#next').click
        Capybara.fill_in('Passwd', with: password)
        Capybara.find('#signIn').click
        wait_until_text_is_present('Welcome back to Firebase')
        puts 'Sign in completed.'
      end

      def self.go_to_settings
        puts 'Going to project settings...'
        Capybara.find('.md-button.md-gmp-blue-theme.md-ink-ripple.md-icon-button').click
        Capybara.find('button', :text => 'Project settings').click
        wait_until_text_is_present('Web API Key')
        puts 'Project settings loaded.'
      end

      def self.update_web_api_key(remoteConfigValues)
        puts 'Updating web api key...'
        web_api_key = Capybara.find('label', :text => 'Web API Key').first(:xpath,".//..").find('span').text()
        remoteConfigValues['firebase_web_api_key'] = web_api_key
        puts 'Web api key updated.'
      end

      def self.create_new_project(project_name)
        puts 'Creating new project: ' + project_name + '...'
        Capybara.find('button', :text => 'CREATE NEW PROJECT').click
        Capybara.find(:xpath, '//input[@placeholder="My awesome project"]').set project_name
        Capybara.find('button', :text => 'CREATE PROJECT').click
        wait_until_text_is_not_present('Create a project')
        puts 'Project ' + project_name + ' created.'
        wait_until_text_is_present('Overview')
        puts 'Project ' + project_name + ' loaded.'
      end

      def self.go_to_project(project_name)
        puts 'Opening ' + project_name + ' project...'
        Capybara.find('md-card', :text => project_name).click
        wait_until_text_is_present('Overview')
        puts 'Project ' + project_name + ' loaded.'
      end

      def self.go_to_remote_config(has_config=false)
        puts 'Going to remote config...'
        Capybara.find('.c5e-entry-displayname', :text => 'Remote Config').first(:xpath,".//..").click
        if has_config
          puts 'Waiting for remote config data...'
          wait_until_text_is_present('ADD PARAMETER')
          Capybara.find('button', :text => 'ADD PARAMETER').click
        else
          puts 'Waiting to add new remote config data...'
          wait_until_text_is_present('ADD YOUR FIRST PARAMETER')
          Capybara.find('button', :text => 'ADD YOUR FIRST PARAMETER').click
        end
        puts 'Remote config loaded.'
      end

      def self.copy_remote_config
        puts 'Copying remote config to memory...'
        remoteConfigValues = {}
        Capybara.all('.r10g-param-row.layout-xs-column.layout-row.flex').each {
          |element|
          remoteConfigValues[element.find('.r10g-codefont.r10g-param-row-key.fb-highlightable').text()] = element.find('.chip-value.fb-highlightable').text()
        }
        puts 'Remote config copied.'
        return remoteConfigValues
      end

      def self.paste_remote_config(remoteConfigValues)
        puts 'Pasting remote config from memory...'
        remoteConfigValues.each do | key, value |
          Capybara.find(:xpath, '//input[@name="paramKey"]').set key
          Capybara.find(:xpath, '//input[@placeholder="(empty string)"]').set value
          Capybara.find('button', :text => 'ADD PARAMETER').click
          Capybara.find('button', :text => 'ADD PARAMETER').click
        end
        Capybara.find('button', :text => 'CANCEL').click
        puts 'Remote config pasted.'
      end

      def self.publish_changes
        puts 'Publishing remote config...'
        Capybara.find('button.md-secondary', :text => 'PUBLISH CHANGES').click
        Capybara.find('button.md-primary', :text => 'PUBLISH CHANGES').click
        wait_until_text_is_present('Published')
        puts 'Remote config published.'
      end

      def self.clone_firebase_remote_config
        print 'Email: '
        email = gets.chomp
        print 'Password: '
        password = STDIN.noecho(&:gets).chomp
        puts
        print 'Source(Project Name): '
        source_project = gets.chomp
        print 'Destination(New Project Name): '
        destination_project = gets.chomp

        # overrides selenium's driver to use chrome browser
        Capybara.register_driver :chrome_driver do |app|
          Capybara::Selenium::Driver.new(app, {:browser => :chrome})
        end

        # selecting the driver
        Capybara.default_driver = :chrome_driver

        Capybara.visit 'https://console.firebase.google.com/'
        do_login(email, password)

        go_to_project(source_project)
        go_to_remote_config(true)

        remoteConfigValues = copy_remote_config()
        Capybara.visit 'https://console.firebase.google.com/'
        wait_until_text_is_present('Welcome back to Firebase')

        if !Capybara.has_text? destination_project
          create_new_project(destination_project)
        else
          go_to_project(destination_project)
        end

        go_to_settings()
        update_web_api_key(remoteConfigValues)
        go_to_remote_config()

        paste_remote_config(remoteConfigValues)

        publish_changes()
        go_to_settings()

        puts 'Project cloned successfully!!!'
      end

    end
  end
end
