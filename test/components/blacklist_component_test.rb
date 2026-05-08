require "test_helper"

class BlacklistComponentTest < ViewComponent::TestCase
  context "The BlacklistComponent" do
    should "render the user's blacklist rules" do
      user = create(:user, blacklisted_tags: "blue_hair\nrating:explicit")

      render_inline(BlacklistComponent.new(user: user))

      assert_css("#blacklist-box")
      assert_css("a[href*='blue_hair']", text: "blue_hair")
      assert_css("a[href*='rating%3Ae']", text: "rating:e")
    end

    should "pass locked rules to the template" do
      Danbooru.config.stubs(:sensitive_tags).returns(%w[guro scat])
      user = create(:user, blacklisted_tags: "blue_hair", enable_sensitive_tags: false)

      component = BlacklistComponent.new(user: user)
      assert_includes(component.locked_rules, "guro")
      assert_includes(component.locked_rules, "scat")
      assert_includes(component.rules, "guro")
    end

    should "not include locked rules when sensitive tags are enabled" do
      Danbooru.config.stubs(:sensitive_tags).returns(%w[guro scat])
      user = create(:user, blacklisted_tags: "blue_hair", enable_sensitive_tags: true)

      component = BlacklistComponent.new(user: user)
      assert_empty(component.locked_rules)
      assert_not_includes(component.rules, "guro")
    end
  end
end
