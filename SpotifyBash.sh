#!/bin/bash


while true; do
    echo "1. Kullanıcı girişi yap ve playlist seç."
    echo "2. Komutu sonlandır"

    read -p "Lütfen bir seçenek seçin: " choice

    case $choice in
        1)
        
   echo "Lütfen kullanıcı profilinizin size özel oluşturulan kodunu giriniz. Eğer bilmiyorsanız ->> https://open.spotify.com adresinden profilinizin altındaki profil kısmına tıkladığınızda tarayıcınızın URL kısmında https://open.spotify.com/user/KULLANICI_KODUNUZ yazmaktadır. :"
   read usersId

   if [[ -z "$usersId" ]]; then
    echo "Boş bir girdi girdiniz. Uygulama kapanıyor."
    exit 0
else
    echo "Girdi: $usersId"
fi
  usersid=$(echo $usersId| sed 's/^"//' | sed 's/"$//')
         
response=$(curl -s -X POST "https://accounts.spotify.com/api/token" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "grant_type=client_credentials&client_id=8efc0e420e584e31b86c85e5b7b0e7c1&client_secret=79d32d52f7454835b0013fef6eca1ddb")

access_token=$(echo $response | jq -r '.access_token')


response=$(curl --request GET \
        --url https://api.spotify.com/v1/users/$usersid/playlists \
        --header "Authorization: Bearer $access_token")


    curl --request GET \
  --url https://api.spotify.com/v1/users/$usersid/playlists \
  --header "Authorization: Bearer $access_token" \ | jq '.items[] | {name: .name, id: .id}'


echo "Bir playlist seçiniz :"
read playlist_name
select playlist_name in "${playlist_names[@]}"; do
  break
done

playlist_id=$(curl --request GET \
  --url https://api.spotify.com/v1/users/ry8kjqk9wdxtpwu141tw70xrf/playlists \
  --header "Authorization: Bearer $access_token" | jq --arg name "$playlist_name" '.items[] | select(.name == $name) | .id')
echo " "
echo "$playlist_name Playlistini seçtiniz. Seçilen playlistin içerisindeki şarkılar getiriliyor."
echo " "
playlistId=$(echo $playlist_id | sed 's/^"//' | sed 's/"$//')

# curl --request GET \
#   https://api.spotify.com/v1/playlists/$playlistId/tracks \
#   --header "Authorization: Bearer $access_token" | jq -r '.items[] | "\(.track.artists[0].name) - \(.track.name)"'

playlist2txt=$(curl --request GET \
  https://api.spotify.com/v1/playlists/$playlistId/tracks \
  --header "Authorization: Bearer $access_token" \
  | jq -r '.items[] | "\(.track.artists[0].name) - \(.track.name)"')

  echo "Dosya'ya yazdırmak ister misiniz Y/N ? "
  read yazdir
  if [[ yazdir == "N" ]]; then
  echo "Playlist kaydedilmedi ve uygulama kapanıyor."
  exit 1
else
  echo "$playlist2txt" > playlist_tracks.txt
  echo "Playlist playlist_tracks.txt olarak kaydedildi."
fi

            ;;
        2)
            echo "Hoşçakalın."
            exit 0
            ;;
        *)
            echo "Geçersiz seçenek, lütfen tekrar deneyin."
            ;;
    esac
done

