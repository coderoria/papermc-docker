#!/bin/bash

# Enter server directory
cd papermc

# Set nullstrings back to 'latest'
: ${MC_VERSION:='latest'}
: ${PAPER_BUILD:='latest'}

# Lowercase these to avoid 404 errors on wget
MC_VERSION="${MC_VERSION,,}"
PAPER_BUILD="${PAPER_BUILD,,}"
PROJECT="paper"

# Get version information and build download URL and jar name
if [[ $PAPER_BUILD == latest ]]
then
  # Get the latest build
  PAPER_BUILD=$(curl -s https://api.papermc.io/v2/projects/${PROJECT}/versions/${MC_VERSION}/builds | \
    jq -r '.builds | map(select(.channel == "default") | .build) | .[-1]')
fi
JAR_NAME="${PROJECT}-${MC_VERSION}-${PAPER_BUILD}.jar"

# Update if necessary
if [[ ! -e $JAR_NAME ]]
then
  # Remove old server jar(s)
  rm -f *.jar
  # Download new server jar
  curl -o "$JAR_NAME" "https://api.papermc.io/v2/projects/${PROJECT}/versions/${MC_VERSION}/builds/${PAPER_BUILD}/downloads/${JAR_NAME}"
fi

# Update eula.txt with current setting
echo "eula=${EULA:-false}" > eula.txt

# Add RAM options to Java options if necessary
if [[ -n $MC_RAM ]]
then
  JAVA_OPTS="-Xms${MC_RAM} -Xmx${MC_RAM} $JAVA_OPTS"
fi

# Start server
exec java -server $JAVA_OPTS -jar "$JAR_NAME" nogui
