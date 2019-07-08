defmodule PhoenixCourse.Order do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias PhoenixCourse.{Repo, User, Product, OrderProduct}

  @timestamps_opts [type: :utc_datetime, usec: false]
  schema "orders" do
    field(:status, :string)
    belongs_to(:user, User)
    many_to_many(:products, Product, join_through: OrderProduct, on_replace: :delete)
    timestamps()
  end

  @doc false
  def changeset(order, attrs \\ %{}) do
    changeset =
      order
      |> cast(attrs, [:status, :user_id])
      |> validate_required([:status, :user_id])
      |> validate_inclusion(:status, ["in_progress", "confirmed", "received"])

    case attrs do
      %{"products" => products} ->
        put_assoc(changeset, :products, Product.all_by_ids(products))

      _ ->
        changeset
    end
  end

  def new(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert()
  end

  def all() do
    Repo.all(__MODULE__)
  end

  def all_preloaded() do
    Repo.preload(all(), [:products, :user])
  end

  def get(id) do
    Repo.get!(__MODULE__, id)
  end

  def get_preloaded(id) do
    id
    |> get()
    |> Repo.preload([:products, :user])
  end

  def update_by_id(id, params) do
    id
    |> get_preloaded()
    |> changeset(params)
    |> Repo.update()
  end

  def delete_by_id(id) do
    id
    |> get()
    |> Repo.delete()
  end
end
