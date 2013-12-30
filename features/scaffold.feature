Feature: Wordpress code scaffolding

  Background:
    Given a WP install

  @theme
  Scenario: Scaffold a child theme
    Given I run `wp theme path`
    And save STDOUT as {THEME_DIR}

    When I run `wp scaffold child-theme zombieland --parent_theme=umbrella --theme_name=Zombieland --author=Tallahassee --author_uri=http://www.wp-cli.org --theme_uri=http://www.zombieland.com --activate`
    Then STDOUT should not be empty
    And the {THEME_DIR}/zombieland/style.css file should exist

  @tax @cpt
  Scenario: Scaffold a Custom Taxonomy and Custom Post Type and write it to active theme
    Given I run `wp eval 'echo STYLESHEETPATH;'`
    And save STDOUT as {STYLESHEETPATH}

    When I run `wp scaffold taxonomy zombie-speed --theme`
    Then the {STYLESHEETPATH}/taxonomies/zombie-speed.php file should exist

    When I run `wp scaffold post-type zombie --theme`
    Then the {STYLESHEETPATH}/post-types/zombie.php file should exist

  # Test for all flags but --label, --theme, --plugin and --raw
  @tax
  Scenario: Scaffold a Custom Taxonomy and attach it to CPTs including one that is prefixed and has a text domain
    When I run `wp scaffold taxonomy zombie-speed --post_types="prefix-zombie,wraith" --textdomain=zombieland`
    Then STDOUT should contain:
      """
      __( 'Zombie speeds'
      """
    And STDOUT should contain:
      """
      array( 'prefix-zombie', 'wraith' )
      """
    And STDOUT should contain:
      """
      __( 'Zombie speeds', 'zombieland'
      """
  
  @tax
  Scenario: Scaffold a Custom Taxonomy with label "Speed"
    When I run `wp scaffold taxonomy zombie-speed --label="Speed"`
    Then STDOUT should contain:
        """
        __( 'Speeds'
        """
    And STDOUT should contain:
        """
        _x( 'Speed', 'taxonomy general name',
        """

  # Test for all flags but --label, --theme, --plugin and --raw
  @cpt
  Scenario: Scaffold a Custom Post Type
    When I run `wp scaffold post-type zombie --textdomain=zombieland`
    Then STDOUT should contain:
      """
      __( 'Zombies'
      """
    And STDOUT should contain:
      """
      __( 'Zombies', 'zombieland'
      """

  @cpt
  Scenario: Scaffold a Custom Post Type with label
    When I run `wp scaffold post-type zombie --label="Brain eater"`
    Then STDOUT should contain:
      """
      __( 'Brain eaters'
      """
  
  # Test the custom template with custom variables functionality
  @cpt @tax
  Scenario: Scaffold a custom post type and taxonomy based on a custom template
    Given I run `wp eval 'echo STYLESHEETPATH;'`
    And save STDOUT as {STYLESHEETPATH}
    And a custom.mustache file:
      """
      Custom template with written by {{custom_var}}
      """
    When I run `wp scaffold cpt zombie --template_path=custom.mustache --custom_var=Daryl --theme`
    Then the {STYLESHEETPATH}/post-types/zombie.php file should contain:
      """
      Custom template with written by Daryl
      """

    When I run `wp scaffold tax zombie --template_path=custom.mustache --custom_var=Daryl --theme`
    Then the {STYLESHEETPATH}/taxonomies/zombie.php file should contain:
      """
      Custom template with written by Daryl
      """

  @plugin
  Scenario: Scaffold plugin with custom template WP-CLI config file in WordPress root directory a.k.a. project level
    And I run `wp plugin path`
    And save STDOUT as {PLUGIN_DIR}
    And a zombie-plugin.mustache file:
      """
      Custom plugin template with written by {{custom_var}}
      """
    When I run `wp scaffold plugin zombieland --template_path=zombie-plugin.mustache --custom_var=Daryl`
    Then the {PLUGIN_DIR}/zombieland/zombieland.php file should contain:
      """
      Custom plugin template with written by Daryl
      """