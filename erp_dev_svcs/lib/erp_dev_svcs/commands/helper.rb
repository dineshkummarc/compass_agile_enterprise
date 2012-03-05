module ErpDevSvcs
  module Commands
    class Helper
      COMPASS_ROOT = "lib/compass_agile_enterprise"
      COMMERCIAL_ROOT = "lib/truenorth"

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
        find_rails_root!

        code_dirs = [COMPASS_ROOT, COMMERCIAL_ROOT]
        code_dirs.each do |code_dir|
          begin
            Dir.chdir(code_dir)
            root_dir = Dir.pwd

            #we're using gemspecs to know that we have
            #a mountable engine located there
            gemspecs = Dir.glob("**/*.gemspec")
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
          rescue Errno::ENOENT => e
            puts "#{code_dir} does not exist; skipping..."
          end
        end
      end

      def self.compass_gem_names
         [:erp_base_erp_svcs,
                     :erp_dev_svcs,
                     :erp_tech_svcs,
                     :erp_forms,
                     :erp_agreements,
                     :erp_products,
                     :erp_orders,
                     :erp_txns_and_accts,
                     :erp_commerce,
                     :erp_inventory,
                     :erp_communication_events,
                     :erp_invoicing,
                     :erp_rules,
                     :erp_work_effort,
                     :erp_financial_accounting,
                     :compass_ae_console,
                     :knitkit,
                     :rails_db_admin,
                     :compass_ae_starter_kit,
                     :erp_search,
                     :erp_app]
      end

    end
  end
end
