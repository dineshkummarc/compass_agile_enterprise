module ErpDevSvcs
  module Commands
    class Helper
      COMPASS_ROOT = "lib/compass_agile_enterprise"
      COMMERCIAL_ROOT = "lib/truenorth"

      KEY_ENGINES = {0  => 'erp_base_erp_svcs/erp_base_erp_svcs.gemspec',
                     1  => 'erp_tech_svcs/erp_tech_svcs.gemspec',
                     2  => 'erp_dev_svcs/erp_dev_svcs.gemspec',
                     3  => 'erp_app/erp_app.gemspec',
                     4  => 'erp_agreements/erp_agreements.gemspec',
                     5  => 'erp_products/erp_products.gemspec',
                     6  => 'erp_orders/erp_orders.gemspec',
                     7  => 'erp_txns_and_accts/erp_txns_and_accts.gemspec',
                     8  => 'erp_commerce/erp_commerce.gemspec',
                     9  => 'erp_inventory/erp_inventory.gemspec',
                     10 => 'erp_work_effort/erp_work_effort.gemspec'}

      def self.find_rails_root!
        if in_rails_application?
          return
        else
          Dir.chdir("..")
          find_rails_root!
        end
      end

      def self.in_rails_application?
        File.exists?(File.join('config', 'boot.rb'))
      end

      def self.sort_gems gemspecs
        KEY_ENGINES.each do |key, val|
          gemspecs.delete(val)
        end
        KEY_ENGINES.each do |key, val|
          gemspecs.insert(key, val)
        end
        gemspecs
      end

      ##
      #Will set the cwd to each engine under
      #compass/lib and execute the block passed in.
      #Will return cwd to lib/compass.
      #
      #This method also accepts an alternate parameter of
      #an array with engine names in it. If present,the
      #block will only be executed on the engines listed in
      #that array
      def self.exec_in_engines(only_in_these_gems = nil)

        code_dirs = [COMPASS_ROOT, COMMERCIAL_ROOT]
        code_dirs.each do |code_dir|
          begin
            find_rails_root!
            Dir.chdir(code_dir)
            root_dir = Dir.pwd

            #we're using gemspecs to know that we have
            #a mountable engine located there
            gemspecs = Dir.glob("**/*.gemspec")
            gemspecs = sort_gems(gemspecs) if code_dir == COMPASS_ROOT
            gemspecs.each do |gem|
              #XXX:we're skipping compass_ae since all it does is
              #help install compass
              next if gem == "compass_ae.gemspec"
              gemspec = /(.*)\/(.*.gemspec)/.match(gem)
              #set engine name to the submatch via "[1]"
              engine_name = /(.*).gemspec/.match(gemspec[2])[1]

              if only_in_these_gems.nil? || only_in_these_gems.include?(engine_name)
                Dir.chdir(gemspec[1])
                #pass in the engine name
                yield engine_name
                Dir.chdir(root_dir)
              end
            end
          rescue Errno::ENOENT
            puts "#{code_dir} does not exist; skipping..."
          end
        end

      end

      ##
      #This will cd into the COMPASS_ROOT and COMMERCIAL_DIR
      #and execute the passed block; in COMMERCIAL_DIR, it will
      #cd to the subdir and execute each command.  The assumption here
      #is that you're trying to perform a command on individual repos
      def self.exec_in_dirs
        begin
          find_rails_root!
          Dir.chdir(COMPASS_ROOT)
          puts "Operating on compass root dir..."
          yield

          find_rails_root!
          Dir.chdir(COMMERCIAL_ROOT)
          root_dir = Dir.pwd
          puts "Now operating on commercial repos..."
          Dir.foreach(".") do |dir_item|
            next if dir_item == '..' || dir_item == '.'
            if File.directory?(dir_item)
              Dir.chdir(dir_item)
              puts "\nChanging to #{dir_item}...\n"
              yield
              Dir.chdir(root_dir)
            end
          end
        rescue Errno::ENOENT => e
          puts "#{e.message} does not exist; skipping..."
        end
      end

      def self.compass_gem_names
         [:erp_base_erp_svcs,
                     :erp_dev_svcs,
                     :erp_tech_svcs,
                     :erp_app,
                     :erp_forms,
                     :erp_agreements,
                     :erp_products,
                     :erp_orders,
                     :erp_txns_and_accts,
                     :erp_commerce,
                     :erp_inventory,
                     :erp_communication_events,
                     :erp_rules,
                     :erp_work_effort,
                     :erp_invoicing,
                     :erp_financial_accounting,
                     :compass_ae_console,
                     :knitkit,
                     :rails_db_admin,
                     :compass_ae_starter_kit,
                     :erp_search]
      end

    end
  end
end
