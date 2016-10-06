require "firebase/cloning/tool/version"
require 'capybara'
require 'capybara/dsl'
require 'pry'
require 'io/console'

module Firebase
  module Cloning
    module Tool

      def self.wait_until_selector_present(selector, wait=10)
        wait.times do
          break     if Capybara.all(selector).any?
          puts 'Waiting for selector: ' + selector + '...'
          sleep 1
        end
      end

      def self.wait_until_xpath_present(xpath, wait=10)
        wait.times do
          break     if Capybara.all(:xpath, xpath).any?
          puts 'Waiting for xpath: ' + xpath + '...'
          sleep 1
        end
      end

      def self.do_login(email, password)
        puts 'Trying sign in for ' + email + '...'
        wait_until_selector_present('#Email')
        Capybara.fill_in('Email', with: email)
        wait_until_selector_present('#next')
        Capybara.find('#next').click
        wait_until_selector_present('#Passwd')
        Capybara.fill_in('Passwd', with: password)
        wait_until_selector_present('#signIn')
        Capybara.find('#signIn').click
        wait_until_selector_present('div.c5e-landing-welcome-existing-projects-title')
        puts 'Sign in completed.'
      end

      def self.go_to_settings
        puts 'Going to project settings...'
        wait_until_xpath_present('//button[@aria-label="Settings" and contains(@class, "md-icon-button")]')
        Capybara.find(:xpath, '//button[@aria-label="Settings" and contains(@class, "md-icon-button")]').click
        wait_until_xpath_present('//button[@ng-click="controller.navEntryClick(controller.settings)"]')
        Capybara.find(:xpath, '//button[@ng-click="controller.navEntryClick(controller.settings)"]').click
        wait_until_xpath_present('//span[@ng-if="::controller.webApiKey"]')
        puts 'Project settings loaded.'
      end

      def self.update_web_api_key(remoteConfigValues)
        if !remoteConfigValues.key?('firebase_web_api_key')
          return
        end
        puts 'Updating web api key...'
        web_api_key = Capybara.find(:xpath, '//span[@ng-if="::controller.webApiKey"]').text
        remoteConfigValues['firebase_web_api_key'] = web_api_key
        puts 'Web api key updated.'
      end

      def self.create_new_project(project_name)
        puts 'Creating new project: ' + project_name + '...'
        Capybara.find(:xpath, '//button[@ng-click="controller.showCreateProjectDialog()"]').click
        Capybara.find(:xpath, '//input[@name="projectName"]').set project_name
        Capybara.find(:xpath, '//button[@ng-click="controller.createProject()"]').click
        wait_until_xpath_present('//button[@ng-click="controller.closeCreateProjectDialog()"]')
        puts 'Project ' + project_name + ' created.'
        wait_until_selector_present('div.fb-featurebar-title')
        puts 'Project ' + project_name + ' loaded.'
      end

      def self.go_to_project(project_name)
        puts 'Opening ' + project_name + ' project...'
        Capybara.find('md-card', :text => project_name).click
        wait_until_selector_present('div.fb-featurebar-title')
        puts 'Project ' + project_name + ' loaded.'
      end

      def self.go_to_remote_config()
        puts 'Going to remote config...'
        Capybara.find('.c5e-entry-displayname', :text => 'Remote Config').first(:xpath,".//..").click

        wait_until_selector_present('div.fb-featurebar-title')

        if Capybara.all('img.fb-zero-state-image').any?
          puts 'Waiting to add new remote config data...'
          wait_until_xpath_present('//button[@ng-click="fbButtonCtaClick($event)"]')
          Capybara.find(:xpath, '//button[@ng-click="fbButtonCtaClick($event)"]').click
        else
          puts 'Waiting for remote config data...'
          wait_until_xpath_present('//button[@ng-click="controller.addParameter($event)"]')
          Capybara.find(:xpath, '//button[@ng-click="controller.addParameter($event)"]').click
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
          Capybara.find(:xpath, '//input[@ng-model="property:controller.valueOption.value"]').set value
          if Capybara.all(:xpath, '//button[@ng-click="controller.addParameter($event)"]').any?
            Capybara.find(:xpath, '//button[@ng-click="controller.addParameter($event)"]').click
          else
            Capybara.find(:xpath, '//button[@ng-click="pe.onSubmitHandler()"]').click
          end
          Capybara.find(:xpath, '//button[@ng-click="controller.addParameter($event)"]').click
        end
        Capybara.find(:xpath, '//button[@ng-click="pe.onCancel()"]').click
        puts 'Remote config pasted.'
      end

      def self.publish_changes
        puts 'Publishing remote config...'
        Capybara.find(:xpath, '//button[@ng-click="featureBar.primaryButton.buttonAction()"]').click
        Capybara.find(:xpath, '//button[@ng-click="$ctrl.continue()"]').click
        wait_until_selector_present('div.md-toast-content')
        puts 'Remote config published.'
      end

      def self.clone_firebase_remote_config
        print 'Email: '
        email = gets.chomp
        print 'Password: '
        password = STDIN.noecho(&:gets).chomp
        puts
        print 'Source(Project Name, Case sensitive): '
        source_project = gets.chomp
        print 'Destination(New Project Name, Case sensitive, Only letters, numbers, spaces, and these characters: -!\'") : '
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
        go_to_remote_config()

        remoteConfigValues = copy_remote_config()
        Capybara.visit 'https://console.firebase.google.com/'
        wait_until_selector_present('div.c5e-landing-welcome-existing-projects-title')

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
