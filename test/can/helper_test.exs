defmodule Can.HelperTest do
  use ExUnit.Case
  doctest Can.Helper
  alias Can.Helper

  defmodule FooPolicy do
    def show?(user, doc) do
      doc.user_id == user.id
    end
  end

  defmodule Foo.BarPolicy do
  end

  test "makes sure that the policy module is actually defined" do
    assert Helper.verify_policy!(FooPolicy) == FooPolicy
  end

  test "works with nested module names" do
    assert Helper.verify_policy!(Foo.BarPolicy) == Foo.BarPolicy
  end

  test "raises for undefined policies" do
    assert_raise Can.Exception.UndefinedPolicyError, "undefined policy: UndefinedPolicy.", fn ->
      Helper.verify_policy!(UndefinedPolicy)
    end
  end

  test "returns the conventional policy name, like: User -> UserPolicy" do
    assert Helper.policy_module(User) == UserPolicy
  end

  test "also works with nested modules" do
    assert Helper.policy_module(MyApp.Users) == MyApp.UsersPolicy
  end

  test "correctly calls a function on a given policy module" do
    user = %{id: 1, name: "some user"}
    doc  = %{id: 2, user_id: 1, name: "some doc"}
    assert Helper.apply_policy(FooPolicy, :show?, [user, doc]) == true
    assert Helper.apply_policy(FooPolicy, :show?, [%{user | id: 2}, doc]) == false
  end
end
