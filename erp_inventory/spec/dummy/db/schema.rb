# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110921150854) do

  create_table "agreement_item_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agreement_item_types", ["parent_id"], :name => "index_agreement_item_types_on_parent_id"

  create_table "agreement_items", :force => true do |t|
    t.integer  "agreement_id"
    t.integer  "agreement_item_type_id"
    t.string   "agreement_item_value"
    t.string   "description"
    t.string   "agreement_item_rule_string"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agreement_items", ["agreement_id"], :name => "index_agreement_items_on_agreement_id"
  add_index "agreement_items", ["agreement_item_type_id"], :name => "index_agreement_items_on_agreement_item_type_id"

  create_table "agreement_party_roles", :force => true do |t|
    t.string   "description"
    t.integer  "agreement_id"
    t.integer  "party_id"
    t.integer  "role_type_id"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agreement_party_roles", ["agreement_id"], :name => "index_agreement_party_roles_on_agreement_id"
  add_index "agreement_party_roles", ["party_id"], :name => "index_agreement_party_roles_on_party_id"
  add_index "agreement_party_roles", ["role_type_id"], :name => "index_agreement_party_roles_on_role_type_id"

  create_table "agreement_relationships", :force => true do |t|
    t.integer  "agreement_reln_type_id"
    t.string   "description"
    t.integer  "agreement_id_from"
    t.integer  "agreement_id_to"
    t.integer  "role_type_id_from"
    t.integer  "role_type_id_to"
    t.integer  "status_type_id"
    t.date     "from_date"
    t.date     "thru_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agreement_relationships", ["agreement_reln_type_id"], :name => "index_agreement_relationships_on_agreement_reln_type_id"
  add_index "agreement_relationships", ["status_type_id"], :name => "index_agreement_relationships_on_status_type_id"

  create_table "agreement_reln_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "valid_from_role_type_id"
    t.integer  "valid_to_role_type_id"
    t.string   "name"
    t.string   "description"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agreement_reln_types", ["parent_id"], :name => "index_agreement_reln_types_on_parent_id"
  add_index "agreement_reln_types", ["valid_from_role_type_id"], :name => "index_agreement_reln_types_on_valid_from_role_type_id"
  add_index "agreement_reln_types", ["valid_to_role_type_id"], :name => "index_agreement_reln_types_on_valid_to_role_type_id"

  create_table "agreement_role_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agreement_role_types", ["parent_id"], :name => "index_agreement_role_types_on_parent_id"

  create_table "agreement_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agreement_types", ["parent_id"], :name => "index_agreement_types_on_parent_id"

  create_table "agreements", :force => true do |t|
    t.string   "description"
    t.integer  "agreement_type_id"
    t.string   "agreement_status"
    t.integer  "product_id"
    t.date     "agreement_date"
    t.date     "from_date"
    t.date     "thru_date"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agreements", ["agreement_type_id"], :name => "index_agreements_on_agreement_type_id"
  add_index "agreements", ["product_id"], :name => "index_agreements_on_product_id"

  create_table "app_containers", :force => true do |t|
    t.integer  "user_id"
    t.string   "description"
    t.string   "internal_identifier"
    t.integer  "app_container_record_id"
    t.string   "app_container_record_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_containers", ["user_id"], :name => "index_app_containers_on_user_id"

  create_table "app_containers_applications", :id => false, :force => true do |t|
    t.integer  "app_container_id"
    t.integer  "application_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_containers_applications", ["app_container_id"], :name => "index_app_containers_applications_on_app_container_id"
  add_index "app_containers_applications", ["application_id"], :name => "index_app_containers_applications_on_application_id"

  create_table "applications", :force => true do |t|
    t.string   "description"
    t.string   "icon"
    t.string   "internal_identifier"
    t.string   "javascript_class_name"
    t.string   "shortcut_id"
    t.string   "type"
    t.string   "resource_loader",       :default => "ErpApp::ApplicationResourceLoader::FileSystemLoader"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "applications_roles", :id => false, :force => true do |t|
    t.integer  "application_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "applications_roles", ["application_id"], :name => "index_applications_roles_on_application_id"
  add_index "applications_roles", ["role_id"], :name => "index_applications_roles_on_role_id"

  create_table "applications_widgets", :id => false, :force => true do |t|
    t.integer  "application_id"
    t.integer  "widget_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "applications_widgets", ["application_id"], :name => "index_applications_widgets_on_application_id"
  add_index "applications_widgets", ["widget_id"], :name => "index_applications_widgets_on_widget_id"

  create_table "audit_log_item_types", :force => true do |t|
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.string   "description"
    t.string   "comments"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audit_log_items", :force => true do |t|
    t.integer  "audit_log_id"
    t.integer  "audit_log_item_type_id"
    t.string   "audit_log_item_value"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audit_log_types", :force => true do |t|
    t.string   "description"
    t.string   "error_code"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audit_logs", :force => true do |t|
    t.string   "application"
    t.string   "descriptio"
    t.integer  "party_id"
    t.text     "additional_info"
    t.integer  "audit_log_type_id"
    t.integer  "event_record_id"
    t.string   "event_record_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audit_logs", ["event_record_id", "event_record_type"], :name => "event_record_index"
  add_index "audit_logs", ["party_id"], :name => "index_audit_logs_on_party_id"

  create_table "base_txn_contexts", :force => true do |t|
    t.integer  "biz_txn_event_id"
    t.integer  "txn_context_record_id"
    t.string   "txn_context_record_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "base_txn_contexts", ["txn_context_record_id", "txn_context_record_type"], :name => "txn_context_record_idx"

  create_table "biz_acct_txn_tasks", :force => true do |t|
    t.integer  "biz_txn_task_id"
    t.integer  "biz_txn_account_id"
    t.string   "description"
    t.string   "comments"
    t.datetime "entered_date"
    t.datetime "requested_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_acct_txn_tasks", ["biz_txn_account_id"], :name => "index_biz_acct_txn_tasks_on_biz_txn_account_id"
  add_index "biz_acct_txn_tasks", ["biz_txn_task_id"], :name => "index_biz_acct_txn_tasks_on_biz_txn_task_id"

  create_table "biz_txn_acct_party_roles", :force => true do |t|
    t.string   "description"
    t.integer  "biz_txn_acct_root_id"
    t.integer  "party_id"
    t.integer  "biz_txn_acct_pty_rtype_id"
    t.integer  "is_default_billing_acct_flag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_txn_acct_party_roles", ["biz_txn_acct_pty_rtype_id"], :name => "index_biz_txn_acct_party_roles_on_biz_txn_acct_pty_rtype_id"
  add_index "biz_txn_acct_party_roles", ["biz_txn_acct_root_id"], :name => "index_biz_txn_acct_party_roles_on_biz_txn_acct_root_id"
  add_index "biz_txn_acct_party_roles", ["party_id"], :name => "index_biz_txn_acct_party_roles_on_party_id"

  create_table "biz_txn_acct_pty_rtypes", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_txn_acct_pty_rtypes", ["parent_id"], :name => "index_biz_txn_acct_pty_rtypes_on_parent_id"

  create_table "biz_txn_acct_rel_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_txn_acct_rel_types", ["parent_id"], :name => "index_biz_txn_acct_rel_types_on_parent_id"

  create_table "biz_txn_acct_relationships", :force => true do |t|
    t.integer  "biz_txn_acct_rel_type_id"
    t.string   "description"
    t.integer  "biz_txn_acct_root_id_from"
    t.integer  "biz_txn_acct_root_id_to"
    t.integer  "status_type_id"
    t.date     "from_date"
    t.date     "thru_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_txn_acct_relationships", ["biz_txn_acct_rel_type_id"], :name => "index_biz_txn_acct_relationships_on_biz_txn_acct_rel_type_id"
  add_index "biz_txn_acct_relationships", ["status_type_id"], :name => "index_biz_txn_acct_relationships_on_status_type_id"

  create_table "biz_txn_acct_roots", :force => true do |t|
    t.string   "description"
    t.integer  "status"
    t.integer  "biz_txn_acct_id"
    t.string   "biz_txn_acct_type"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_txn_acct_roots", ["biz_txn_acct_id", "biz_txn_acct_type"], :name => "btai_2"

  create_table "biz_txn_acct_status_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "biz_txn_acct_statuses", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "biz_txn_acct_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_txn_acct_types", ["parent_id"], :name => "index_biz_txn_acct_types_on_parent_id"

  create_table "biz_txn_agreement_role_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_txn_agreement_role_types", ["parent_id"], :name => "index_biz_txn_agreement_role_types_on_parent_id"

  create_table "biz_txn_agreement_roles", :force => true do |t|
    t.integer  "biz_txn_event_id"
    t.string   "biz_txn_event_type"
    t.integer  "agreement_id"
    t.integer  "biz_txn_agreement_role_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_txn_agreement_roles", ["agreement_id"], :name => "index_biz_txn_agreement_roles_on_agreement_id"
  add_index "biz_txn_agreement_roles", ["biz_txn_agreement_role_type_id"], :name => "index_biz_txn_agreement_roles_on_biz_txn_agreement_role_type_id"

  create_table "biz_txn_event_descs", :force => true do |t|
    t.integer  "biz_txn_event_id"
    t.integer  "language_id"
    t.integer  "locale_id"
    t.integer  "priority"
    t.integer  "sequence"
    t.string   "short_description"
    t.string   "long_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_txn_event_descs", ["biz_txn_event_id"], :name => "index_biz_txn_event_descs_on_biz_txn_event_id"
  add_index "biz_txn_event_descs", ["language_id"], :name => "index_biz_txn_event_descs_on_language_id"
  add_index "biz_txn_event_descs", ["locale_id"], :name => "index_biz_txn_event_descs_on_locale_id"

  create_table "biz_txn_events", :force => true do |t|
    t.string   "description"
    t.integer  "biz_txn_acct_root_id"
    t.integer  "biz_txn_type_id"
    t.datetime "entered_date"
    t.datetime "post_date"
    t.integer  "biz_txn_record_id"
    t.string   "biz_txn_record_type"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_txn_events", ["biz_txn_acct_root_id"], :name => "index_biz_txn_events_on_biz_txn_acct_root_id"
  add_index "biz_txn_events", ["biz_txn_record_id", "biz_txn_record_type"], :name => "btai_1"
  add_index "biz_txn_events", ["biz_txn_type_id"], :name => "index_biz_txn_events_on_biz_txn_type_id"

  create_table "biz_txn_party_role_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_txn_party_role_types", ["parent_id"], :name => "index_biz_txn_party_role_types_on_parent_id"

  create_table "biz_txn_party_roles", :force => true do |t|
    t.integer  "biz_txn_event_id"
    t.integer  "party_id"
    t.integer  "biz_txn_party_role_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_txn_party_roles", ["biz_txn_event_id"], :name => "index_biz_txn_party_roles_on_biz_txn_event_id"
  add_index "biz_txn_party_roles", ["biz_txn_party_role_type_id"], :name => "index_biz_txn_party_roles_on_biz_txn_party_role_type_id"
  add_index "biz_txn_party_roles", ["party_id"], :name => "index_biz_txn_party_roles_on_party_id"

  create_table "biz_txn_rel_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_txn_rel_types", ["parent_id"], :name => "index_biz_txn_rel_types_on_parent_id"

  create_table "biz_txn_relationships", :force => true do |t|
    t.integer  "biz_txn_rel_type_id"
    t.string   "description"
    t.integer  "txn_event_id_from"
    t.integer  "txn_event_id_to"
    t.integer  "status_type_id"
    t.date     "from_date"
    t.date     "thru_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_txn_relationships", ["biz_txn_rel_type_id"], :name => "index_biz_txn_relationships_on_biz_txn_rel_type_id"
  add_index "biz_txn_relationships", ["status_type_id"], :name => "index_biz_txn_relationships_on_status_type_id"

  create_table "biz_txn_statuses", :force => true do |t|
    t.string   "description"
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "biz_txn_task_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_txn_task_types", ["parent_id"], :name => "index_biz_txn_task_types_on_parent_id"

  create_table "biz_txn_tasks", :force => true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "biz_txn_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "biz_txn_types", ["parent_id"], :name => "index_biz_txn_types_on_parent_id"

  create_table "categories", :force => true do |t|
    t.string   "description"
    t.string   "external_identifier"
    t.datetime "from_date"
    t.datetime "to_date"
    t.string   "internal_identifier"
    t.integer  "category_record_id"
    t.string   "category_record_type"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["category_record_id", "category_record_type"], :name => "category_polymorphic"

  create_table "category_classifications", :force => true do |t|
    t.integer  "category_id"
    t.string   "classification_type"
    t.integer  "classification_id"
    t.datetime "from_date"
    t.datetime "to_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "category_classifications", ["classification_id", "classification_type"], :name => "classification_polymorphic"

  create_table "charge_line_payment_txns", :force => true do |t|
    t.integer  "charge_line_id"
    t.integer  "payment_txn_id"
    t.string   "payment_txn_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "charge_line_payment_txns", ["charge_line_id"], :name => "index_charge_line_payment_txns_on_charge_line_id"
  add_index "charge_line_payment_txns", ["payment_txn_id", "payment_txn_type"], :name => "payment_txn_idx"

  create_table "charge_lines", :force => true do |t|
    t.string   "sti_type"
    t.integer  "money_id"
    t.string   "description"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.integer  "charged_item_id"
    t.string   "charged_item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "charge_lines", ["charged_item_id", "charged_item_type"], :name => "charged_item_idx"

  create_table "compass_ae_instances", :force => true do |t|
    t.decimal  "version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contact_purposes", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contact_purposes", ["parent_id"], :name => "index_contact_purposes_on_parent_id"

  create_table "contact_purposes_contacts", :id => false, :force => true do |t|
    t.integer "contact_id"
    t.integer "contact_purpose_id"
  end

  add_index "contact_purposes_contacts", ["contact_id", "contact_purpose_id"], :name => "contact_purposes_contacts_index"

  create_table "contact_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contact_types", ["parent_id"], :name => "index_contact_types_on_parent_id"

  create_table "contacts", :force => true do |t|
    t.integer  "party_id"
    t.integer  "contact_mechanism_id"
    t.string   "contact_mechanism_type"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["contact_mechanism_id", "contact_mechanism_type"], :name => "besi_2"
  add_index "contacts", ["party_id"], :name => "index_contacts_on_party_id"

  create_table "credit_card_account_party_roles", :force => true do |t|
    t.integer  "credit_card_account_id"
    t.integer  "role_type_id"
    t.integer  "party_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credit_card_account_party_roles", ["credit_card_account_id"], :name => "index_credit_card_account_party_roles_on_credit_card_account_id"
  add_index "credit_card_account_party_roles", ["party_id"], :name => "index_credit_card_account_party_roles_on_party_id"
  add_index "credit_card_account_party_roles", ["role_type_id"], :name => "index_credit_card_account_party_roles_on_role_type_id"

  create_table "credit_card_account_purposes", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credit_card_accounts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credit_cards", :force => true do |t|
    t.string   "crypted_private_card_number"
    t.integer  "expiration_month"
    t.integer  "expiration_year"
    t.string   "description"
    t.string   "first_name_on_card"
    t.string   "last_name_on_card"
    t.string   "card_type"
    t.integer  "postal_address_id"
    t.integer  "credit_card_account_party_role_id"
    t.integer  "credit_card_account_purpose_id"
    t.string   "credit_card_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "currencies", :force => true do |t|
    t.string   "name"
    t.string   "definition"
    t.string   "internal_identifier"
    t.string   "numeric_code"
    t.string   "major_unit_symbol"
    t.string   "minor_unit_symbol"
    t.string   "ratio_of_minor_unit_to_major_unit"
    t.string   "postfix_label"
    t.datetime "introduction_date"
    t.datetime "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "currencies", ["internal_identifier"], :name => "index_currencies_on_internal_identifier"

  create_table "currencies_locales", :force => true do |t|
    t.integer  "currency_id"
    t.integer  "locale_id"
    t.string   "locale_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "currencies_locales", ["currency_id"], :name => "index_currencies_locales_on_currency_id"
  add_index "currencies_locales", ["locale_id", "locale_type"], :name => "besi_3"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "descriptive_assets", :force => true do |t|
    t.integer  "view_type_id"
    t.string   "internal_identifier"
    t.text     "description"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.integer  "described_record_id"
    t.string   "described_record_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "descriptive_assets", ["described_record_id", "described_record_type"], :name => "described_record_idx"
  add_index "descriptive_assets", ["view_type_id"], :name => "index_descriptive_assets_on_view_type_id"

  create_table "desktops", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_addresses", :force => true do |t|
    t.string   "email_address"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fee_types", :force => true do |t|
    t.string   "internal_identifier"
    t.string   "description"
    t.string   "comments"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fees", :force => true do |t|
    t.integer  "fee_record_id"
    t.string   "fee_record_type"
    t.integer  "money_id"
    t.integer  "fee_type_id"
    t.string   "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fees", ["fee_record_id", "fee_record_type"], :name => "fee_record_idx"
  add_index "fees", ["fee_type_id"], :name => "index_fees_on_fee_type_id"
  add_index "fees", ["money_id"], :name => "index_fees_on_money_id"

  create_table "file_assets", :force => true do |t|
    t.integer  "file_asset_holder_id"
    t.string   "file_asset_holder_type"
    t.string   "type"
    t.string   "name"
    t.string   "directory"
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "file_assets", ["file_asset_holder_id", "file_asset_holder_type"], :name => "file_asset_holder_idx"
  add_index "file_assets", ["type"], :name => "index_file_assets_on_type"

  create_table "financial_txn_accounts", :force => true do |t|
    t.string   "description"
    t.string   "account_number"
    t.integer  "agreement_id"
    t.integer  "balance_id"
    t.integer  "payment_due_id"
    t.datetime "due_date"
    t.integer  "financial_account_id"
    t.string   "financial_account_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "financial_txn_assns", :force => true do |t|
    t.integer  "financial_txn_id"
    t.integer  "financial_txn_record_id"
    t.string   "financial_txn_record_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "financial_txns", :force => true do |t|
    t.integer  "money_id"
    t.integer  "integer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "four_oh_fours", :force => true do |t|
    t.string   "url"
    t.string   "referer"
    t.integer  "count",          :default => 0
    t.string   "remote_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geo_countries", :force => true do |t|
    t.string   "name"
    t.string   "iso_code_2"
    t.string   "iso_code_3"
    t.boolean  "display",     :default => true
    t.integer  "external_id"
    t.datetime "created_at"
  end

  add_index "geo_countries", ["iso_code_2"], :name => "index_geo_countries_on_iso_code_2"
  add_index "geo_countries", ["name"], :name => "index_geo_countries_on_name"

  create_table "geo_zones", :force => true do |t|
    t.integer  "geo_country_id"
    t.string   "zone_code",      :default => "2"
    t.string   "zone_name"
    t.datetime "created_at"
  end

  add_index "geo_zones", ["geo_country_id"], :name => "index_geo_zones_on_geo_country_id"
  add_index "geo_zones", ["zone_code"], :name => "index_geo_zones_on_zone_code"
  add_index "geo_zones", ["zone_name"], :name => "index_geo_zones_on_zone_name"

  create_table "individuals", :force => true do |t|
    t.integer  "party_id"
    t.string   "current_last_name"
    t.string   "current_first_name"
    t.string   "current_middle_name"
    t.string   "current_personal_title"
    t.string   "current_suffix"
    t.string   "current_nickname"
    t.string   "gender",                       :limit => 1
    t.date     "birth_date"
    t.decimal  "height",                                    :precision => 5, :scale => 2
    t.integer  "weight"
    t.string   "mothers_maiden_name"
    t.string   "marital_status",               :limit => 1
    t.string   "social_security_number"
    t.integer  "current_passport_number"
    t.date     "current_passport_expire_date"
    t.integer  "total_years_work_experience"
    t.string   "comments"
    t.string   "encrypted_ssn"
    t.string   "temp_ssn"
    t.string   "salt"
    t.string   "ssn_last_four"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "individuals", ["party_id"], :name => "index_individuals_on_party_id"

  create_table "inv_entry_reln_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inv_entry_reln_types", ["parent_id"], :name => "index_inv_entry_reln_types_on_parent_id"

  create_table "inv_entry_relns", :force => true do |t|
    t.integer  "inv_entry_reln_type_id"
    t.string   "description"
    t.integer  "inv_entry_id_from"
    t.integer  "inv_entry_id_to"
    t.integer  "role_type_id_from"
    t.integer  "role_type_id_to"
    t.integer  "status_type_id"
    t.date     "from_date"
    t.date     "thru_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inv_entry_relns", ["inv_entry_reln_type_id"], :name => "index_inv_entry_relns_on_inv_entry_reln_type_id"
  add_index "inv_entry_relns", ["status_type_id"], :name => "index_inv_entry_relns_on_status_type_id"

  create_table "inv_entry_role_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inv_entry_role_types", ["parent_id"], :name => "index_inv_entry_role_types_on_parent_id"

  create_table "inventory_entries", :force => true do |t|
    t.string   "description"
    t.integer  "inventory_entry_record_id"
    t.string   "inventory_entry_record_type"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.integer  "product_type_id"
    t.integer  "number_available"
    t.string   "sku"
    t.integer  "number_sold"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inventory_entries", ["inventory_entry_record_id", "inventory_entry_record_type"], :name => "bii_1"

  create_table "invitations", :force => true do |t|
    t.integer  "sender_id"
    t.string   "email"
    t.string   "token"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["sender_id"], :name => "index_invitations_on_sender_id"

  create_table "line_item_role_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "line_item_role_types", ["parent_id"], :name => "index_line_item_role_types_on_parent_id"

  create_table "logged_exceptions", :force => true do |t|
    t.string   "exception_class"
    t.string   "controller_name"
    t.string   "action_name"
    t.text     "message"
    t.text     "backtrace"
    t.text     "environment"
    t.text     "request"
    t.datetime "created_at"
  end

  add_index "logged_exceptions", ["created_at"], :name => "index_logged_exceptions_on_created_at"

  create_table "loyalty_program_codes", :force => true do |t|
    t.string   "identifier"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "money", :force => true do |t|
    t.string   "description"
    t.float    "amount"
    t.integer  "currency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "money", ["currency_id"], :name => "index_money_on_currency_id"

  create_table "note_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.integer  "note_type_record_id"
    t.string   "note_type_record_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "note_types", ["note_type_record_id", "note_type_record_type"], :name => "note_type_record_idx"

  create_table "notes", :force => true do |t|
    t.integer  "created_by_id"
    t.text     "content"
    t.integer  "noted_record_id"
    t.string   "noted_record_type"
    t.integer  "note_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["content"], :name => "index_notes_on_content"
  add_index "notes", ["created_by_id"], :name => "index_notes_on_created_by_id"
  add_index "notes", ["note_type_id"], :name => "index_notes_on_note_type_id"
  add_index "notes", ["noted_record_id", "noted_record_type"], :name => "index_notes_on_noted_record_id_and_noted_record_type"

  create_table "order_line_item_pty_roles", :force => true do |t|
    t.string   "description"
    t.integer  "order_line_item_id"
    t.integer  "party_id"
    t.integer  "line_item_role_type_id"
    t.integer  "biz_txn_acct_root_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_line_item_pty_roles", ["biz_txn_acct_root_id"], :name => "index_order_line_item_pty_roles_on_biz_txn_acct_root_id"
  add_index "order_line_item_pty_roles", ["line_item_role_type_id"], :name => "index_order_line_item_pty_roles_on_line_item_role_type_id"
  add_index "order_line_item_pty_roles", ["order_line_item_id"], :name => "index_order_line_item_pty_roles_on_order_line_item_id"
  add_index "order_line_item_pty_roles", ["party_id"], :name => "index_order_line_item_pty_roles_on_party_id"

  create_table "order_line_item_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_line_item_types", ["parent_id"], :name => "index_order_line_item_types_on_parent_id"

  create_table "order_line_items", :force => true do |t|
    t.integer  "order_txn_id"
    t.integer  "order_line_item_type_id"
    t.integer  "product_id"
    t.string   "product_description"
    t.integer  "product_instance_id"
    t.string   "product_instance_description"
    t.integer  "product_type_id"
    t.string   "product_type_description"
    t.float    "sold_price"
    t.integer  "sold_price_uom"
    t.integer  "sold_amount"
    t.integer  "sold_amount_uom"
    t.integer  "product_offer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_line_items", ["order_line_item_type_id"], :name => "index_order_line_items_on_order_line_item_type_id"
  add_index "order_line_items", ["order_txn_id"], :name => "index_order_line_items_on_order_txn_id"
  add_index "order_line_items", ["product_id"], :name => "index_order_line_items_on_product_id"
  add_index "order_line_items", ["product_instance_id"], :name => "index_order_line_items_on_product_instance_id"
  add_index "order_line_items", ["product_offer_id"], :name => "index_order_line_items_on_product_offer_id"
  add_index "order_line_items", ["product_type_id"], :name => "index_order_line_items_on_product_type_id"

  create_table "order_txn_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_txn_types", ["parent_id"], :name => "index_order_txn_types_on_parent_id"

  create_table "order_txns", :force => true do |t|
    t.string   "state_machine"
    t.string   "description"
    t.integer  "order_txn_type_id"
    t.string   "email"
    t.string   "phone_number"
    t.string   "ship_to_first_name"
    t.string   "ship_to_last_name"
    t.string   "ship_to_address_line_1"
    t.string   "ship_to_address_line_2"
    t.string   "ship_to_city"
    t.string   "ship_to_state"
    t.string   "ship_to_postal_code"
    t.string   "ship_to_country_name"
    t.string   "customer_ip"
    t.integer  "order_number"
    t.string   "status"
    t.string   "error_message"
    t.integer  "order_txn_record_id"
    t.string   "order_txn_record_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payment_gateway_txn_id"
    t.integer  "credit_card_id"
    t.string   "bill_to_first_name"
    t.string   "bill_to_last_name"
    t.string   "bill_to_address_line_1"
    t.string   "bill_to_address_line_2"
    t.string   "bill_to_city"
    t.string   "bill_to_state"
    t.string   "bill_to_postal_code"
    t.string   "bill_to_country_name"
    t.string   "bill_to_country"
    t.string   "ship_to_country"
  end

  add_index "order_txns", ["order_txn_record_id", "order_txn_record_type"], :name => "order_txn_record_idx"
  add_index "order_txns", ["order_txn_type_id"], :name => "index_order_txns_on_order_txn_type_id"

  create_table "organizations", :force => true do |t|
    t.string   "description"
    t.string   "tax_id_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parties", :force => true do |t|
    t.string   "description"
    t.integer  "business_party_id"
    t.string   "business_party_type"
    t.integer  "list_view_image_id"
    t.string   "enterprise_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "parties", ["business_party_id", "business_party_type"], :name => "besi_1"

  create_table "party_relationships", :force => true do |t|
    t.string   "description"
    t.integer  "party_id_from"
    t.integer  "party_id_to"
    t.integer  "role_type_id_from"
    t.integer  "role_type_id_to"
    t.integer  "status_type_id"
    t.integer  "priority_type_id"
    t.integer  "relationship_type_id"
    t.date     "from_date"
    t.date     "thru_date"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "party_relationships", ["priority_type_id"], :name => "index_party_relationships_on_priority_type_id"
  add_index "party_relationships", ["relationship_type_id"], :name => "index_party_relationships_on_relationship_type_id"
  add_index "party_relationships", ["status_type_id"], :name => "index_party_relationships_on_status_type_id"

  create_table "party_roles", :force => true do |t|
    t.string   "type"
    t.integer  "party_id"
    t.integer  "role_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "party_roles", ["party_id"], :name => "index_party_roles_on_party_id"
  add_index "party_roles", ["role_type_id"], :name => "index_party_roles_on_role_type_id"

  create_table "party_search_facts", :force => true do |t|
    t.integer  "party_id"
    t.string   "eid"
    t.string   "type"
    t.text     "roles"
    t.string   "party_description"
    t.string   "party_business_party_type"
    t.string   "user_login"
    t.string   "individual_current_last_name"
    t.string   "individual_current_first_name"
    t.string   "individual_current_middle_name"
    t.string   "individual_birth_date"
    t.string   "individual_ssn"
    t.string   "party_phone_number"
    t.string   "party_email_address"
    t.string   "party_address_1"
    t.string   "party_address_2"
    t.string   "party_primary_address_city"
    t.string   "party_primary_address_state"
    t.string   "party_primary_address_zip"
    t.string   "party_primary_address_country"
    t.boolean  "user_enabled"
    t.string   "user_type"
    t.boolean  "reindex"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_gateway_actions", :force => true do |t|
    t.string   "internal_identifier"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_gateway_actions", ["internal_identifier"], :name => "index_payment_gateway_actions_on_internal_identifier"

  create_table "payment_gateways", :force => true do |t|
    t.string   "params"
    t.integer  "payment_gateway_action_id"
    t.integer  "payment_id"
    t.string   "response"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", :force => true do |t|
    t.boolean  "success"
    t.string   "reference_number"
    t.integer  "financial_txn_id"
    t.string   "current_state"
    t.string   "authorization_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payments", ["financial_txn_id"], :name => "index_payments_on_financial_txn_id"

  create_table "phone_numbers", :force => true do |t|
    t.string   "phone_number"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "postal_addresses", :force => true do |t|
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.string   "description"
    t.integer  "geo_country_id"
    t.integer  "geo_zone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "postal_addresses", ["geo_country_id"], :name => "index_postal_addresses_on_geo_country_id"
  add_index "postal_addresses", ["geo_zone_id"], :name => "index_postal_addresses_on_geo_zone_id"

  create_table "preference_options", :force => true do |t|
    t.string   "description"
    t.string   "internal_identifier"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "preference_options_preference_types", :id => false, :force => true do |t|
    t.integer  "preference_type_id"
    t.integer  "preference_option_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preference_options_preference_types", ["preference_option_id"], :name => "pref_opt_pref_type_pref_opt_id_idx"
  add_index "preference_options_preference_types", ["preference_type_id"], :name => "pref_opt_pref_type_pref_type_id_idx"

  create_table "preference_types", :force => true do |t|
    t.string   "description"
    t.string   "internal_identifier"
    t.integer  "default_pref_option_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preference_types", ["default_pref_option_id"], :name => "index_preference_types_on_default_pref_option_id"

  create_table "preferences", :force => true do |t|
    t.integer  "preference_option_id"
    t.integer  "preference_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferences", ["preference_option_id"], :name => "index_preferences_on_preference_option_id"
  add_index "preferences", ["preference_type_id"], :name => "index_preferences_on_preference_type_id"

  create_table "price_component_types", :force => true do |t|
    t.string   "description"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "price_components", :force => true do |t|
    t.string   "description"
    t.integer  "pricing_plan_component_id"
    t.integer  "price_id"
    t.integer  "money_id"
    t.integer  "priced_component_id"
    t.string   "priced_component_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "price_components", ["money_id"], :name => "index_price_components_on_money_id"
  add_index "price_components", ["price_id"], :name => "index_price_components_on_price_id"
  add_index "price_components", ["priced_component_id", "priced_component_type"], :name => "priced_component_idx"
  add_index "price_components", ["pricing_plan_component_id"], :name => "index_price_components_on_pricing_plan_component_id"

  create_table "prices", :force => true do |t|
    t.string   "description"
    t.integer  "priced_item_id"
    t.string   "priced_item_type"
    t.integer  "pricing_plan_id"
    t.integer  "money_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prices", ["money_id"], :name => "index_prices_on_money_id"
  add_index "prices", ["priced_item_id", "priced_item_type"], :name => "priced_item_idx"
  add_index "prices", ["pricing_plan_id"], :name => "index_prices_on_pricing_plan_id"

  create_table "pricing_plan_assignments", :force => true do |t|
    t.integer  "pricing_plan_id"
    t.integer  "priceable_item_id"
    t.string   "priceable_item_type"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pricing_plan_assignments", ["priceable_item_id", "priceable_item_type"], :name => "priceable_item_idx"
  add_index "pricing_plan_assignments", ["pricing_plan_id"], :name => "index_pricing_plan_assignments_on_pricing_plan_id"

  create_table "pricing_plan_components", :force => true do |t|
    t.integer  "price_component_type_id"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.string   "matching_rules"
    t.string   "pricing_calculation"
    t.boolean  "is_simple_amount"
    t.integer  "currency_id"
    t.float    "money_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pricing_plan_components", ["price_component_type_id"], :name => "index_pricing_plan_components_on_price_component_type_id"

  create_table "pricing_plans", :force => true do |t|
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.date     "from_date"
    t.date     "thru_date"
    t.string   "matching_rules"
    t.string   "pricing_calculation"
    t.boolean  "is_simple_amount"
    t.integer  "currency_id"
    t.float    "money_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prod_availability_status_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prod_instance_inv_entries", :force => true do |t|
    t.integer  "product_instance_id"
    t.integer  "inventory_entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prod_instance_inv_entries", ["inventory_entry_id"], :name => "index_prod_instance_inv_entries_on_inventory_entry_id"
  add_index "prod_instance_inv_entries", ["product_instance_id"], :name => "index_prod_instance_inv_entries_on_product_instance_id"

  create_table "prod_instance_reln_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prod_instance_reln_types", ["parent_id"], :name => "index_prod_instance_reln_types_on_parent_id"

  create_table "prod_instance_relns", :force => true do |t|
    t.integer  "prod_instance_reln_type_id"
    t.string   "description"
    t.integer  "prod_instance_id_from"
    t.integer  "prod_instance_id_to"
    t.integer  "role_type_id_from"
    t.integer  "role_type_id_to"
    t.integer  "status_type_id"
    t.date     "from_date"
    t.date     "thru_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prod_instance_relns", ["prod_instance_reln_type_id"], :name => "index_prod_instance_relns_on_prod_instance_reln_type_id"
  add_index "prod_instance_relns", ["status_type_id"], :name => "index_prod_instance_relns_on_status_type_id"

  create_table "prod_instance_role_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prod_instance_role_types", ["parent_id"], :name => "index_prod_instance_role_types_on_parent_id"

  create_table "prod_type_reln_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prod_type_reln_types", ["parent_id"], :name => "index_prod_type_reln_types_on_parent_id"

  create_table "prod_type_relns", :force => true do |t|
    t.integer  "prod_type_reln_type_id"
    t.string   "description"
    t.integer  "prod_type_id_from"
    t.integer  "prod_type_id_to"
    t.integer  "role_type_id_from"
    t.integer  "role_type_id_to"
    t.integer  "status_type_id"
    t.date     "from_date"
    t.date     "thru_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prod_type_relns", ["prod_type_reln_type_id"], :name => "index_prod_type_relns_on_prod_type_reln_type_id"
  add_index "prod_type_relns", ["status_type_id"], :name => "index_prod_type_relns_on_status_type_id"

  create_table "prod_type_role_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prod_type_role_types", ["parent_id"], :name => "index_prod_type_role_types_on_parent_id"

  create_table "product_instance_status_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_instances", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.integer  "product_instance_record_id"
    t.string   "product_instance_record_type"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.integer  "product_type_id"
    t.string   "type"
    t.integer  "prod_availability_status_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_instances", ["parent_id"], :name => "index_product_instances_on_parent_id"
  add_index "product_instances", ["product_instance_record_id", "product_instance_record_type"], :name => "bpi_2"
  add_index "product_instances", ["product_type_id"], :name => "index_product_instances_on_product_type_id"

  create_table "product_offers", :force => true do |t|
    t.string   "description"
    t.integer  "product_offer_record_id"
    t.string   "product_offer_record_type"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_offers", ["product_offer_record_id", "product_offer_record_type"], :name => "bpi_3"

  create_table "product_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.integer  "product_type_record_id"
    t.string   "product_type_record_type"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.string   "default_image_url"
    t.integer  "list_view_image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_types", ["parent_id"], :name => "index_product_types_on_parent_id"
  add_index "product_types", ["product_type_record_id", "product_type_record_type"], :name => "bpi_1"

  create_table "relationship_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "valid_from_role_type_id"
    t.integer  "valid_to_role_type_id"
    t.string   "name"
    t.string   "description"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationship_types", ["valid_from_role_type_id"], :name => "index_relationship_types_on_valid_from_role_type_id"
  add_index "relationship_types", ["valid_to_role_type_id"], :name => "index_relationship_types_on_valid_to_role_type_id"

  create_table "role_types", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "description"
    t.string   "comments"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "description"
    t.string   "internal_identifier"
    t.string   "external_identifier"
    t.string   "external_id_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_secured_models", :id => false, :force => true do |t|
    t.integer  "secured_model_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles_secured_models", ["role_id"], :name => "index_roles_secured_models_on_role_id"
  add_index "roles_secured_models", ["secured_model_id"], :name => "index_roles_secured_models_on_secured_model_id"

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "roles_widgets", :id => false, :force => true do |t|
    t.integer  "widget_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles_widgets", ["widget_id", "role_id"], :name => "index_roles_widgets_on_widget_id_and_role_id"

  create_table "secured_models", :force => true do |t|
    t.integer  "secured_record_id"
    t.string   "secured_record_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "secured_models", ["secured_record_id", "secured_record_type"], :name => "secured_record_idx"

  create_table "security_questions", :force => true do |t|
    t.string   "question"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_captcha_data", ["key", "value"], :name => "btsi_3"

  create_table "simple_product_offers", :force => true do |t|
    t.string   "description"
    t.integer  "product_id"
    t.float    "base_price"
    t.integer  "uom"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_product_offers", ["product_id"], :name => "index_simple_product_offers_on_product_id"

  create_table "tree_menu_node_defs", :force => true do |t|
    t.string   "node_type"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "menu_short_name"
    t.string   "menu_description"
    t.string   "text"
    t.string   "icon_url"
    t.string   "target_url"
    t.string   "resource_class"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tree_menu_node_defs", ["parent_id"], :name => "index_tree_menu_node_defs_on_parent_id"

  create_table "user_failures", :force => true do |t|
    t.string   "remote_ip"
    t.string   "http_user_agent"
    t.string   "failure_type"
    t.string   "username"
    t.integer  "count",           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_failures", ["remote_ip"], :name => "btsi_1"
  add_index "user_failures", ["username"], :name => "index_user_failures_on_username"

  create_table "user_preferences", :force => true do |t|
    t.integer  "user_id"
    t.integer  "preference_id"
    t.integer  "preferenced_record_id"
    t.string   "preferenced_record_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_preferences", ["preference_id"], :name => "index_user_preferences_on_preference_id"
  add_index "user_preferences", ["preferenced_record_id"], :name => "index_user_preferences_on_preferenced_record_id"
  add_index "user_preferences", ["preferenced_record_type"], :name => "index_user_preferences_on_preferenced_record_type"
  add_index "user_preferences", ["user_id"], :name => "index_user_preferences_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "username"
    t.integer  "party_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["party_id"], :name => "index_users_on_party_id", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "valid_note_types", :force => true do |t|
    t.integer  "valid_note_type_record_id"
    t.string   "valid_note_type_record_type"
    t.integer  "note_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "valid_note_types", ["note_type_id"], :name => "index_valid_note_types_on_note_type_id"
  add_index "valid_note_types", ["valid_note_type_record_id", "valid_note_type_record_type"], :name => "valid_note_type_record_idx"

  create_table "valid_preference_types", :force => true do |t|
    t.integer "preference_type_id"
    t.integer "preferenced_record_id"
    t.string  "preferenced_record_type"
  end

  create_table "valid_price_plan_components", :force => true do |t|
    t.integer  "pricing_plan_id"
    t.integer  "pricing_plan_component_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "valid_price_plan_components", ["pricing_plan_component_id"], :name => "index_valid_price_plan_components_on_pricing_plan_component_id"
  add_index "valid_price_plan_components", ["pricing_plan_id"], :name => "index_valid_price_plan_components_on_pricing_plan_id"

  create_table "view_types", :force => true do |t|
    t.string   "internal_identifier"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "widgets", :force => true do |t|
    t.string   "description"
    t.string   "internal_identifier"
    t.string   "icon"
    t.string   "xtype"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
