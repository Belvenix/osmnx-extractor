1. Install WSL subsystem
2. Run following commands:
   <code> 
   apt-get update
   apt-get install -y osmium-tool osmctools dos2unix
   dos2unix extract.sh
   apt-get install python3-pip
   python3 -m pip install networkx
   python3 -m pip install git+https://github.com/Belvenix/osmnx.git@main
   
   </code>
3. Install Docker Desktop on host machine (windows)
4. Install docker-compose in WSL using: `apt-get install docker-compose`
5. On host machine in Docker Desktop go to `Settings->Resources->WSL Integration` and turn on integration for WSL distro
    Note: Docker Desktop version is `4.6.1`
6. Start using osmnx-extractor

