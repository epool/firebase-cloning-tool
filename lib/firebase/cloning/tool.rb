require "firebase/cloning/tool/version"
require 'capybara'
require 'capybara/dsl'
require 'pry'
require 'io/console'

module Firebase
  module Cloning
    module Tool

      def self.wait_until_selector_present(selector, wait=30)
        wait.times do
          break     if Capybara.all(selector).any?
          puts 'Waiting for selector: ' + selector + '...'
          sleep 1
        end
      end

      def self.wait_until_selector_disapears(selector, wait=30)
        wait.times do
          break     if !Capybara.all(selector).any?
          puts 'Waiting for selector to disapears: ' + selector + '...'
          sleep 1
        end
      end

      def self.wait_until_xpath_present(xpath, wait=30)
        wait.times do
          break     if Capybara.all(:xpath, xpath).any?
          puts 'Waiting for xpath: ' + xpath + '...'
          sleep 1
        end
      end

      def self.wait_until_xpath_disapears(xpath, wait=30)
        wait.times do
          break     if !Capybara.all(:xpath, xpath).any?
          puts 'Waiting for xpath: ' + xpath + '...'
          sleep 1
        end
      end

      def self.do_login(email, password)
        puts 'Trying sign in for ' + email + '...'
        wait_until_selector_present('#identifierId')
        Capybara.fill_in('identifierId', with: email)
        wait_until_selector_present('#identifierNext')
        Capybara.find('#identifierNext').click
        wait_until_xpath_present('//input[@name="password"]')
        # Capybara.fill_in('Passwd', with: password)
        Capybara.find(:xpath, '//input[@name="password"]').set(password)
        wait_until_selector_present('#passwordNext')
        Capybara.find('#passwordNext').click
        wait_until_selector_present('div.c5e-landing-create-project-button')
        puts 'Sign in completed.'
      end

      def self.create_new_project(project_name)
        puts 'Creating new project: ' + project_name + '...'
        Capybara.find('div.c5e-landing-create-project-button').click
        wait_until_selector_disapears('circle.ng-star-inserted')
        wait_until_xpath_present('//input[@name="projectName"]')
        Capybara.find(:xpath, '//input[@name="projectName"]').set project_name
        Capybara.find('#mat-checkbox-2-input').first(:xpath,".//..").click
        wait_until_xpath_disapears('//button[@ng-click="controller.createProject()" and @disabled="disabled"]')
        Capybara.find(:xpath, '//button[@ng-click="controller.createProject()"]').click
        wait_until_xpath_present('//button[@name="continueButton"]')
        Capybara.find(:xpath, '//button[@name="continueButton"]').click
        puts 'Project ' + project_name + ' created.'
        wait_until_selector_present('div.fb-featurebar-title')
        puts 'Project ' + project_name + ' loaded.'
      end

      def self.go_to_project(project_name)
        puts 'Opening ' + project_name + ' project...'
        Capybara.find('div.c5e-project-card-project-name', :exact_text => project_name).click
        wait_until_selector_present('div.fb-featurebar-title')
        puts 'Project ' + project_name + ' loaded.'
      end

      def self.go_to_remote_config
        puts 'Going to remote config...'
        Capybara.find('.c5e-entry-displayname', :text => 'Remote Config').first(:xpath,".//..").click

        wait_until_selector_present('div.fb-featurebar-title')

        if Capybara.all('img.fire-zero-state-image').any?
          puts 'Waiting to add new remote config data...'
          wait_until_xpath_present('//*[@id="main"]/ng-transclude/div/div/div/r10g-ng2-parameter-list/div/div/mat-card/fire-zero-state/div/button')
          Capybara.find(:xpath, '//*[@id="main"]/ng-transclude/div/div/div/r10g-ng2-parameter-list/div/div/mat-card/fire-zero-state/div/button').click
        else
          puts 'Waiting for remote config data...'
          wait_until_selector_present('button.mat-raised-button.mat-primary.ng-star-inserted')
          # Capybara.find('button.mat-raised-button.mat-primary.ng-star-inserted').click
        end
        puts 'Remote config loaded.'
      end

      def self.copy_remote_config
        puts 'Copying remote config to memory...'
        remote_config_values = {}
        Capybara.all('div.content').each {
          |element|
          remote_config_values[element.find('div.name').text()] = element.find('div.chip-value.value.ng-star-inserted div.ng-star-inserted').text()
        }
        puts 'Remote config copied.'
        return remote_config_values
      end

      def self.project_exists(project_name)
        Capybara.all('div.c5e-project-card-project-name').each {
          |element|
          if element.text() == project_name
            return true
          end
        }
        return false
      end

      def self.paste_remote_config(remote_config_values)
        puts 'Pasting remote config from memory...'
        remote_config_values.each do | key, value |
          Capybara.find(:xpath, '//*[@id="main"]/ng-transclude/div/div/div/r10g-ng2-parameter-list/div/div/mat-card/fire-inline-editor/div/r10g-ng2-parameter-editor/form/div/div[2]/div[1]/div[1]/input').set key
          Capybara.find(:xpath, '//*[@id="main"]/ng-transclude/div/div/div/r10g-ng2-parameter-list/div/div/mat-card/fire-inline-editor/div/r10g-ng2-parameter-editor/form/div/div[2]/div[2]/div/r10g-ng2-parameter-conditional-value-editor/div/div/r10g-ng2-parameter-conditional-value-input/div/input').set value
          Capybara.find(:xpath, '//*[@id="main"]/ng-transclude/div/div/div/r10g-ng2-parameter-list/div/div/mat-card/fire-inline-editor[1]/div/r10g-ng2-parameter-editor/form/div/div[3]/div[2]/button[2]').click
          Capybara.find(:xpath, '//*[@id="main"]/ng-transclude/div/div/div[2]/r10g-ng2-parameter-list/div/div/mat-card/fire-card-action-bar/div/div/button').click
        end
        Capybara.find(:xpath, '//*[@id="main"]/ng-transclude/div/div/div[2]/r10g-ng2-parameter-list/div/div/mat-card/fire-inline-editor[1]/div/r10g-ng2-parameter-editor/form/div/div[3]/div[2]/button[1]').click
        puts 'Remote config pasted.'
      end

      def self.publish_changes
        puts 'Publishing remote config...'
        Capybara.find(:xpath, '//*[@id="main"]/ng-transclude/fb-feature-bar/div/div/div[2]/div/button').click
        wait_until_selector_present('div.fire-dialog-actions button.mat-primary')
        Capybara.find('div.fire-dialog-actions button.mat-primary').click
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
        do_login("eduardo.alejandro.pool.ake@gmail.com", password)

        go_to_project(source_project)
        go_to_remote_config

        remote_config_values = copy_remote_config
        Capybara.visit 'https://console.firebase.google.com/'
        wait_until_selector_present('div.c5e-landing-create-project-button')

        if project_exists(destination_project)
          go_to_project(destination_project)
        else
          create_new_project(destination_project)
        end

        go_to_remote_config

        paste_remote_config(remote_config_values)

        publish_changes

        puts 'Project cloned successfully!!!'
      end

    end
  end
end
