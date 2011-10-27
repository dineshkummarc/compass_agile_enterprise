Feature: update rails table
    In order to update rails tables without writing SQL
    As a data analyst with knowledge of the database in question
    I want to be able to edit table data in-line
    Scenario: update a table row
        Given a table with 1 row with an id column
        When I update the row with some new data
        Then the row with a matching id should be updated in the selected database
