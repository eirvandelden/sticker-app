require "test_helper"

class Parent::ChildrenIndexAvatarTest < ActionDispatch::IntegrationTest
  setup do
    @parent = users(:parent)
    @children = [ child_profiles(:one), child_profiles(:two), child_profiles(:three) ]
  end

  test "index preloads child avatars" do
    attach_avatars
    sign_in_as @parent

    queries = active_storage_queries { get parent_children_path }

    assert_response :success
    assert_operator queries.count, :<=, 2, queries.join("\n")
  end

  private

  def attach_avatars
    @children.each do |child|
      child.user.avatar.attach(
        io: file_fixture("avatar.png").open,
        filename: "avatar.png",
        content_type: "image/png"
      )
    end
  end

  def active_storage_queries(&block)
    queries = []
    subscriber = lambda do |_name, _start, _finish, _id, payload|
      queries << payload[:sql] if active_storage_query?(payload)
    end

    ActiveSupport::Notifications.subscribed(subscriber, "sql.active_record", &block)
    queries
  end

  def active_storage_query?(payload)
    payload[:name] != "SCHEMA" && payload[:sql].match?(/active_storage_(attachments|blobs)/)
  end
end
