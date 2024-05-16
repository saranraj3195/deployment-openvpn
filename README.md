    - name: Deploy to server
      uses: saranraj3195/deployment-openvpn@main
      env:
        DEPLOY_KEY: ${{ secrets.SERVER_SSH_KEY }}
        ARGS: "-avz --delete"
        SERVER_PORT: ${{ secrets.SERVER_PORT }}
        FOLDER: "src/*"
        SERVER_IP: ${{ secrets.SERVER_IP }}
        USERNAME: ${{ secrets.USERNAME }}
        SERVER_DESTINATION: ${{ secrets.SERVER_DESTINATION }}
        VPN_CONFIG: ${{ secrets.VPN_CONFIG }}
        VPN_USERNAME: ${{ secrets.VPN_USERNAME }}
        VPN_PASSWORD: ${{ secrets.VPN_PASSWORD }}
