class SeedTreeMenuDefs < ActiveRecord::Migration
  def self.up
    # declare the tree root
    root = TreeMenuNodeDef.create(  :node_type => 'category',
                                    :menu_short_name => 'data_mgt_scaffolds',
                                    :menu_description => 'Data Mgt Scaffolds'
                                    )

    # declare the categories
    role_and_relationship_category = TreeMenuNodeDef.create(  :node_type => 'category',
                                    :menu_short_name => 'data_mgt_scaffolds',
                                    :text => 'Role and Relationship Types'

                                    )

    # declare the parties individuals and organizations categories
    parties_category = TreeMenuNodeDef.create(  :node_type => 'category',
                                    :menu_short_name => 'data_mgt_scaffolds',
                                    :text => 'Parties, People & Orgs '

                                    )

    # declate Communications Events category
    communication_events_category = TreeMenuNodeDef.create(  :node_type => 'category',
                                    :menu_short_name => 'data_mgt_scaffolds',
                                    :text => 'Communications Events '

                                    )

    # declate Products and Inventory category
    contract_and_agreements_category = TreeMenuNodeDef.create(  :node_type => 'category',
                                    :menu_short_name => 'data_mgt_scaffolds',
                                    :text => 'Contracts and Agreements'

                                    )
    # declate Orders and Line Items category
    orders_and_line_items_category = TreeMenuNodeDef.create(  :node_type => 'category',
                                    :menu_short_name => 'data_mgt_scaffolds',
                                    :text => 'Orders and LineItems'

                                    )
    # declate Orders and Line Items category
    users_and_roles_category = TreeMenuNodeDef.create(  :node_type => 'category',
                                    :menu_short_name => 'data_mgt_scaffolds',
                                    :text => 'Users and User-Roles'

                                    )

    # declare the Desktop Client Provisioning category
    desktop_provisioning_category = TreeMenuNodeDef.create(  :node_type => 'category',
                                    :menu_short_name => 'data_mgt_scaffolds',
                                    :text => 'Desktop Client Provisioning '

                                    )


    # declare the Log category
    logging_category = TreeMenuNodeDef.create(  :node_type => 'category',
                                    :menu_short_name => 'data_mgt_scaffolds',
                                    :text => 'Logging '

                                    )

     # declare the Data Models category
    data_models_category = TreeMenuNodeDef.create(  :node_type => 'category',
                                    :menu_short_name => 'data_mgt_scaffolds',
                                    :text => 'Data Models '

                                    )
    ##############################
    # declare the scaffold links #
    ##############################


    ###########################
    # Roles and Relationships #
    # #########################
    # declare the roles url node
    url_roles = TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Role',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_roles'
                                    )

    # declare the role types url node
    url_role_types = TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Role Types',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_role_types'
                                    )

    # This is an alternate role type url that demonstrates mixing standard RoR, active_scaffold
    # and Extjs
    #url_extjs_role_types = TreeMenuNodeDef.create(  :node_type => 'url',
    #                                  :text => 'Extjs Role Types',
    #                                  :menu_short_name => 'data_mgt_scaffolds',
    #                                  :menu_description => 'Data Mgt Scaffolds',
    #                                  :target_url => '/data_mgt_extjs_role_types'
    #                                )

    # declare the relationship types url node
    url_reln_types = TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Relationship Types',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_relationship_types'
                                    )

    # declare the client url node
    url_clients = TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Clients',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_clients'
                                    )

    # declare the client preferences url node
    url_client_preferences = TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Client Preferences',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_client_preferences'
                                    )
     # declare the client url node
    url_users = TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Users',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_users'
                                    )
    #########################################
    # Parties Individuals and Organizations #
    ########################################
    
    # declare the parties url node
    url_parties = TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Parties',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_parties'
                                    )
    # declare the individuals url node
    url_individuals = TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Individuals',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_individuals'
                                    )
    # declare the individuals url node
    url_organizations = TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Organizations',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_organizations'
                                    )

    #########################
    # communications events #
    #########################
    
    # declare the communications event url node
    url_communication_events = TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Comm. Events',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_communications_events'
                                    )
    # declare the communications event url node
    url_communication_events_purpose_types = TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Comm. Events Purpose Types',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_communications_events_purpose_types'
                                    )
    ############################
    # Contracts and Agreements #
    ############################


    # declare the agreements url node
    url_agreements = TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Agreements',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_agreements'
                                    )

    # declare the agreement Items/terms

    url_agreement_items= TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Agreement Items/Terms',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_agreement_items'
                                    )

    # declare the Agreement parties

    url_agreement_parties= TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Agreement Parties',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_agreement_parties'
                                    )

    # declare the Agreement types

    url_agreement_types= TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Agreement Types',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_agreement_types'
                                    )

    # declare the tem/item types

    url_term_item_types= TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Term/Item Types',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_term_time_types'
                                    )
    ########################
    # Orders and LineItems #
    ########################

    # declare the order transactions url node

    url_order_transactions= TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Order Transactions',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_order_transactions'
                                    )
                                    # declare the order and Line item types
    # declare the order transactions type url node
    url_order_transactions_types= TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Order Transactions Types',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_order_transaction_types'
                                    )
    # declare the order line items type url node
    url_order_line_items= TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Order Line Items',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_order_line_items'
                                    )
    # declare the order line item types type url node
    url_order_line_item_types= TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Order Line Item Types',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_order_line_item_types'
                                    )
    # declare the order line item types type url node
    url_order_line_item_party_roles= TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Order Line Party Roles',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_order_line_item_party_roles'
                                    )
     # declare the order line item types type url node
    url_line_item_role_types= TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Order Line Item Role Types',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_line_item_role_types'
                                    )





    ###########
    # Logging #
    ###########
    url_audit_log= TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Audit Logs',
                                      :menu_short_name => 'data_mgt_scaffolds',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/data_mgt_audit_log'
                                    )

    # declare models to be available from the tree

    model1 = TreeMenuNodeDef.create(  :node_type => 'model_class',
                                          :text => 'Users',
                                          :menu_short_name => 'data_mgt_scaffolds',
                                          :menu_description => 'Data Mgt Scaffolds',
                                          :resource_class => 'User'
                                        )

    model2 = TreeMenuNodeDef.create(  :node_type => 'model_class',
                                          :text => 'Party Data',
                                          :menu_short_name => 'data_mgt_scaffolds',
                                          :menu_description => 'Data Mgt Scaffolds',
                                          :resource_class => 'Party'
                                        )

    model3 = TreeMenuNodeDef.create(  :node_type => 'model_class',
                                          :text => 'Client Preferences',
                                          :menu_short_name => 'data_mgt_scaffolds',
                                          :menu_description => 'Data Mgt Scaffolds',
                                          :resource_class => 'ClientPreference'
                                        )


    # define parent-child relationships

    # add the role-relation ship category to root
    role_and_relationship_category.move_to_child_of root

    # add the parties, individulas and organization category to root
    parties_category.move_to_child_of root
    
    # add the communications category to root
    communication_events_category.move_to_child_of root

    # add the contracts and agreements category to root
    contract_and_agreements_category.move_to_child_of root

    # add the order and line items category to the root
    orders_and_line_items_category.move_to_child_of root

    # add the users and roles category to root
    users_and_roles_category.move_to_child_of root

    # add the desktop provisioning category to root
    desktop_provisioning_category.move_to_child_of root

    # add the log_category to the root
    logging_category.move_to_child_of root

    # add the data_models_category to the root
    data_models_category.move_to_child_of root

    ###########################
    # Roles and Relationships #
    ###########################



    # add the users url to the role relationship category
    url_users.move_to_child_of users_and_roles_category
    # add the roles url to the role relationship category
    url_roles.move_to_child_of users_and_roles_category
    
    # add the role and relationship type urls to the role relationship category
    url_role_types.move_to_child_of role_and_relationship_category
    #url_extjs_role_types.move_to_child_of role_and_relationship_category    
    url_reln_types.move_to_child_of role_and_relationship_category

    # add the clients url to the desktop provisioning category
    url_clients.move_to_child_of desktop_provisioning_category
    # add the clients url to the desktop provisioning category
    url_client_preferences.move_to_child_of desktop_provisioning_category

    ############################################
    # Parties, Individiduals and Organizations #
    ############################################

    # add the parties to the parties category
    url_parties.move_to_child_of parties_category
    # add the individuals to the parties category
    url_individuals.move_to_child_of parties_category
    # add the organizations to the parties category
    url_organizations.move_to_child_of parties_category

    ##################
    # Communications #
    ##################

    url_communication_events.move_to_child_of communication_events_category
    url_communication_events_purpose_types.move_to_child_of communication_events_category

    ############################
    # contracts and agreements #
    # ##########################

    # add the agreements url node to contacts and agreements category
    url_agreements.move_to_child_of contract_and_agreements_category
    # add the agreements items url node to contacts and agreements category
    url_agreement_items.move_to_child_of contract_and_agreements_category
    # add the agreement parties url node to contacts and agreements category
    url_agreement_parties.move_to_child_of contract_and_agreements_category
    # add the agreements typesurl node to contacts and agreements category
    url_agreement_types.move_to_child_of contract_and_agreements_category
    # add the tem item types url node to contacts and agreements category
    url_term_item_types.move_to_child_of contract_and_agreements_category

    #######################
    # Order and LineItems #
    #######################

    # add order transaction url node to orders and line items category
    url_order_transactions.move_to_child_of orders_and_line_items_category
    # add the order transaction types url node to orders and line items category
    url_order_transactions_types.move_to_child_of orders_and_line_items_category
    # add the line items url node to orders and line items  category
    url_order_line_items.move_to_child_of orders_and_line_items_category
    # add the order line item types url node to orders and line items category
    url_order_line_item_types.move_to_child_of orders_and_line_items_category
    # add the order line party roles url node to orders and line items category
    url_order_line_item_party_roles.move_to_child_of orders_and_line_items_category
    # add the line item role types url node to orders and line items category
    url_line_item_role_types.move_to_child_of orders_and_line_items_category
    
    ###########
    # Logging #
    ###########

    # add the audit log url node to the logging category
    url_audit_log.move_to_child_of logging_category

    # add the models to the data models category
    model1.move_to_child_of data_models_category
    model2.move_to_child_of model1         
    model3.move_to_child_of model1 

    ############################################
    # Content Management Tree Menu             #
    ############################################


    cm_root = TreeMenuNodeDef.create(  :node_type => 'category',
                                    :menu_short_name => 'content_mgt_tree',
                                    :menu_description => 'Content Mgt'
                                    )

    # declare the image assets scaffold link
    url_image_assets = TreeMenuNodeDef.create(  :node_type => 'url',
                                      :text => 'Image Assets',
                                      :menu_short_name => 'content_mgt_tree',
                                      :menu_description => 'Data Mgt Scaffolds',
                                      :target_url => '/content_mgt_image_assets'
                                    )

    # add the role-relation ship category to root
    url_image_assets.move_to_child_of cm_root
    
  end

  def self.down
    TreeMenuNodeDef.roots.each do |d| d.destroy end
  end
end
