FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 5000

ENV ASPNETCORE_URLS=http://+:5010

RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
# Copy csproj and restore as distinct layers
COPY ["src/WebApp/WebApp.csproj", "./WebApp.csproj"]
RUN dotnet restore "WebApp.csproj"

# Copy everything else and build
COPY ["src/", "."]
WORKDIR /src
RUN dotnet build "WebApp/WebApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "WebApp/WebApp.csproj" -c Release -o /app/publish

# Build runtime image
FROM base AS final
WORKDIR /app
ENV TZ=UTC
COPY --from=publish /app/publish .


#RUN apt-get update && apt-get install -y --no-install-recommends apt-utils gss-ntlmssp

ENTRYPOINT ["dotnet", "WebApp.dll"]