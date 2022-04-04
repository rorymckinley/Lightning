defmodule LightningWeb.JobLive.FormComponent do
  @moduledoc """
  Form Component for working with a single Job

  A Job's `adaptor` field is a combination of the module name and the version.
  It's formatted as an NPM style string.

  The form allows the user to select a module by name and then it's version,
  while the version dropdown itself references `adaptor` directly.

  Meaning the `adaptor_name` dropdown and assigns value is not persisted.
  """
  use LightningWeb, :live_component

  alias Lightning.{Jobs, AdaptorRegistry, Credentials}

  @impl true
  def update(%{job: job} = assigns, socket) do
    changeset = Jobs.change_job(job)

    {adaptor_name, _, adaptors, versions} =
      get_adaptor_version_options(changeset |> Ecto.Changeset.fetch_field!(:adaptor))

    credentials = Credentials.list_credentials()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:adaptor_name, adaptor_name)
     |> assign(:adaptors, adaptors)
     |> assign(:credentials, credentials)
     |> assign(:versions, versions)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"job" => job_params}, socket) do
    job_params = coerce_params_for_adaptor_list(job_params)

    changeset =
      socket.assigns.job
      |> Jobs.change_job(job_params)
      |> Map.put(:action, :validate)

    {adaptor_name, _, adaptors, versions} =
      get_adaptor_version_options(changeset |> Ecto.Changeset.fetch_field!(:adaptor))

    {:noreply,
     assign(socket, :changeset, changeset)
     |> assign(:adaptor_name, adaptor_name)
     |> assign(:adaptors, adaptors)
     |> assign(:versions, versions)}
  end

  def handle_event("save", %{"job" => job_params}, socket) do
    save_job(socket, socket.assigns.action, job_params)
  end

  defp save_job(socket, :edit, job_params) do
    case Jobs.update_job(socket.assigns.job, job_params) do
      {:ok, _job} ->
        {:noreply,
         socket
         |> put_flash(:info, "Job updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_job(socket, :new, job_params) do
    case Jobs.create_job(job_params) do
      {:ok, _job} ->
        {:noreply,
         socket
         |> put_flash(:info, "Job created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp get_adaptor_version_options(adaptor) do
    # Gets @openfn/language-foo@1.2.3 or @openfn/language-foo

    adaptor_names =
      Lightning.AdaptorRegistry.all()
      |> Enum.map(&Map.get(&1, :name))

    {module_name, version, versions} =
      if adaptor do
        {module_name, version} = Lightning.AdaptorRegistry.resolve_package_name(adaptor)

        versions =
          Lightning.AdaptorRegistry.versions_for(module_name)
          |> List.wrap()
          |> Enum.map(&Map.get(&1, :version))
          |> Enum.map(fn version -> [key: version, value: "#{module_name}@#{version}"] end)

        {module_name, version, [[key: "latest", value: "#{module_name}@latest"] | versions]}
      else
        {nil, nil, []}
      end

    {module_name, version, adaptor_names, versions}
  end

  @doc """
  Coerce any changes to the "Adaptor" dropdown into a new selection on the
  Version dropdown.
  """
  @spec coerce_params_for_adaptor_list(%{String.t() => String.t()}) ::
          %{}
  def coerce_params_for_adaptor_list(job_params) do
    {package, _version} = AdaptorRegistry.resolve_package_name(job_params["adaptor"])
    {package_group, _} = AdaptorRegistry.resolve_package_name(job_params["adaptor_name"])

    cond do
      is_nil(package_group) ->
        Map.merge(job_params, %{"adaptor" => ""})

      package_group !== package ->
        Map.merge(job_params, %{"adaptor" => "#{package_group}@latest"})

      true ->
        job_params
    end
  end
end
