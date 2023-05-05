FROM mcr.microsoft.com/dotnet/aspnet:7.0
WORKDIR /app
EXPOSE 80
COPY WebApplication2/bin/Release/net7.0/publish .
ENTRYPOINT [ "dotnet", "WebApplication2.dll" ]
