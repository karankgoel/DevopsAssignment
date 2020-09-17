# First Stage
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
MAINTAINER karangoel
WORKDIR /build
COPY . .
RUN dotnet publish WebApplication4.sln -c Release -o /app
# Second Stage
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS final
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "WebApplication4.dll"]