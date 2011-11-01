Feature: update rails table
    In order to update rails tables without writing SQL
    As a data analyst with knowledge of the database in question
    I want to be able to edit table data in-line

    Scenario Outline: update a table row
        Given a <table> table with a row where these <columns> equal this <data>
        When I update the row to match this <updated data>
        Then the row with a matching id in the database should match the updated_data

    Scenarios: a table with an 'id' column
        | table      | columns                         | data           | updated_data                  |
        | role_type  | description                     | Customer       | New Customer                  |
        | role_type  | description,internal_identifier | Vendor,vendor  | Preferred Vendor, pref_vendor |


