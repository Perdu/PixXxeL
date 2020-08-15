;*******************************************************************************;
;				PixXxel															;
; Programme écrit en 2009-2010 par Célestin Matte                               ;
;																				;
;*******************************************************************************;

; Informations utiles sur le programme :

;couleur interdites :
;- 0 : couleur du fond
;- 5 : couleur de tir rebond 
;- 6 : couleur des tirs + bombes
;- 9 : couleur des murs et ennemis
;- 10 : couleur des ennemis lorsque rebond

; système de points :
; -1 point par tir rouge ou bombe
; +20 points par ennemi tué
; +2 points par munitions restantes à la fin d'un niveau
; +5 points par bomes restantes à la fin d'un niveau
; Les munitions ou bombes non récupérées ne rapportent pas de points.

;******************* TO DO : *******************		

; bug colision tir-ennemi ; déconnent : le bas dans bas_gauche et dans haut-droit :) ; more or less fix'd (lazy way)
; bug 256 tirs ; + ou - réglé : les 256 premiers tirs continuent de bouger.
; faire des levels !

;---------------------------------------
; afficher un pixel à l'écran
;--------------------------------------
	TITLE	DISPLAY - programme prototype
;---------------------------------------
CSEG SEGMENT
	ASSUME CS:CSEG, DS:CSEG, ES:CSEG
	ORG 100H
	
	.386

efface_ecran EQU grostexte <1000 dup (20h)>,0,1,1 ;efface l'écran
efface_barre EQU texte "            ",5,1,18
efface_barre_editeur EQU texte "                 ",5,1,18
saut_ligne EQU 0dh,0dh
couleur_ennemis equ 5 ;;;5
couleur_murs equ 9
;cmp dx,0 EQU OR DX,DX


texte macro text?, couleur, ligne, colonne
	
LOCAL text, finmac,couleur,ligne,colonne
pusha
mov al,1
mov bh,0
mov bl,couleur
mov cx, finmac - offset text
LEA bp,text
mov dh,ligne
mov dl,colonne
mov ah,13h
int 10h	


jmp short finmac

text db text?
finmac :	
	
popa	
endm

texte_fichier macro text?
LOCAL text, finmac

pusha
	
	mov ah,40h
LEA dx, text ; bouts de texte
mov cx, finmac - offset text
mov bx,num_logique
int 21h

jmp short finmac
text db text?
finmac :
popa

endm

grostexte macro text?, couleur, ligne, colonne
	
LOCAL text, finmac,couleur,ligne,colonne
pusha
mov al,1
mov bh,0
mov bl,couleur
mov cx, finmac - offset text
LEA bp,text
mov dh,ligne
mov dl,colonne
mov ah,13h
int 10h	


jmp finmac

text db text?
finmac :	
	
popa	
endm

construire_mur_horizontal macro col_arr,col_dep,ligne_conc,coul_murs
	
pusha

mov ax,col_arr	; colonne d'arrivée
push ax
mov ax, col_dep ;colonne de départ
push ax
mov ax, ligne_conc ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, coul_murs ;couleur ligne
push ax

CALL trace_ligne

popa

endm

construire_mur_vertical macro ligne_arr,ligne_dep,col_conc,coul_murs2

pusha

mov ax,ligne_arr	; ligne d'arrivée
push ax
mov ax,ligne_dep ;ligne de départ
push ax
mov ax,col_conc ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, coul_murs2 ;couleur ligne
push ax

CALL trace_ligne

popa

endm



ecrire_dans macro numero_logique
push ax
mov ax,numero_logique	
mov num_logique,ax	
pop ax
endm

ouvrir_fichier macro temp, no_logique
pusha
						MOV AH, 3DH
		MOV AL, 02h
		LEA DX, temp
		INT 21H
		mov no_logique,ax

		JC AffERR
popa
	
	endm

fermer_fichier macro nologique

mov ah,3eh
mov bx,nologique
int 21h
;JC AffERR ; for some reason, jwasm fails to find the AffERR symbol here (but finds it 5 lines above!)

endm

copier_fichier macro temp_fichier1, no_logique_fichier1, no_logique_fichier2

	fermer_fichier no_logique_fichier1 ; Pourquoi faire ça ? Parce que DOSBox a une manière bizarre de fonctionner au niveau des fichiers : il doit travailler sur des copies ou un
	ouvrir_fichier temp_fichier1, no_logique_fichier1 ; truc dans le genre. Du coup tant qu'on n'a pas fermé un fichier, on ne peut pas lire ce qu'on vient de mettre dedans.
							; Donc on le ferme et on le rouvre.
lea dx,temp_copie
mov ax,3F00H
mov cx,0FFFFH
mov bx,no_logique_fichier1
int 21h
JC AffERR

mov cx,ax
mov bx,no_logique_fichier2
mov ax,4000h
lea dx,temp_copie
int 21h
JC AffERR
endm




convertir macro registre

mov tempw,registre
CALL conversion	

endm

placer_bombe macro coord_cx, coord_dx

mov cx,coord_cx
mov dx,coord_dx
CALL bombe
push cx
push dx
	
endm

placer_munits macro coord_cx, coord_dx

mov cx,coord_cx
mov dx,coord_dx
CALL munits
push cx
push dx
	
endm

MAIN :


;CALL Editeur_de_niveaux

CALL intro


;JMP fin_du_jeu

retour_menu :
mov points,0
CALL menu

JMP chg_level

LEVEL1 :


;CALL lvlX

CALL lvl1

LEVEL2:
	
CALL lvl2

LEVEL3 :

CALL lvl3

LEVEL4 :

CALL lvl4

LEVEL5 :

CALL lvl5

LEVEL6 :

CALL lvl6

LEVEL7 :

CALL lvl7

LEVEL8 :

CALL lvl8

LEVEL9 :

CALL lvlhardcore

LEVEL10 :

mov al, couleur_sav
mov couleur_vaisseau,al

CALL lvl10

LEVEL11 :

CALL lvl11

LEVEL12 :

CALL lvl12

LEVEL13 :

;CALL lvl3

LEVEL14 :

;CALL lvl4

LEVEL15 :

;CALL lvl5


JMP fin_du_jeu


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ commun à tous les niveaux
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*death
death :

mov cx,colonne_pers
mov dx,ligne_pers
CALL erase_personnage
mov ah, 0ch
mov al,14
inc cx
dec dx
int 10h
inc cx
int 10h
inc cx
int 10h
inc dx
dec cx
int 10h
inc dx
int 10h
inc cx
int 10h 			; dessin de l'étoile d'explosion du vaisseau
inc dx
sub cx,2
int 10h
inc dx
dec cx
int 10h
dec cx
dec dx
int 10h
dec cx
int 10h
dec cx
int 10h
inc cx
dec dx
int 10h
dec dx
int 10h
dec cx
dec dx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
dec dx
int 10h
inc cx
dec dx
int 10h
inc dx
int 10h


texte "You died...  ",14,1,18


cmp vies_inf_on,1
JE mode_vies_infinies2
dec nb_vies
mode_vies_infinies2 :
cmp nb_vies,0
JE partie_perdue

mov ah,8
int 21h

cmp al,1BH
JE FIN

JMP restart

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*next level
next_level :
inc level

mov sp, 0fffeh
mov nb_tirs,0
mov mvt_pers,0
mov ax,0
mov bx,0
mov cx,0
mov dx,0

texte "Good game !! ",14,1,18

mov ax,munitions_canon
shl ax,1 			;multiplie par 2 très très vite 
add points,ax

mov ax,stock_bombes
mov cx,5
mul cx
add points,ax

mov att,18
CALL powse


JMP chg_level
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*restart
restart_sans_perte_de_vie :

mov ax,nb_vies_sav
mov nb_vies,ax

restart :

mov sp, 0fffeh
mov nb_tirs,0
mov ax,points_sav
mov points,ax
mov ax,nb_coeurs_detruits_sav
mov nb_coeurs_detruits,ax
mov mvt_pers,0
mov ax,0
mov bx,0
mov cx,0
mov dx,0

chg_level :
cmp level,1
JE LEVEL1
cmp level,2
JE LEVEL2
cmp level,3
JE LEVEL3
cmp level,4
JE LEVEL4
cmp level,5
JE level5
cmp level,6
JE level6
cmp level,7
JE level7
cmp level,8
JE level8
cmp level,9
JE level9
cmp level,10
JE level10
cmp level,11
JE level11
cmp level,12
JE level12
cmp level,13
JE level13
cmp level,14
JE level14
cmp level,15
JE level15

JMP fin_du_jeu
        
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*partie perdue

partie_perdue :
	
texte "Sorry, you lost...",4,11,12	
	

mov ah,8
int 21h
JMP fin

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*fin du jeu :

fin_du_jeu :

efface_ecran

		mov ah,0bh
	mov bh, 0
	mov bl, 5
	int 10h

texte <"GG ROGER ",1,20h,2,20h,1,20h,2,20h,1,20h,2,20h,1,20h,2>,17,7,7
	
texte "SCORE : ",17,9,4

cmp cheat_active,0
JZ pas_de_cheat_end

texte "Finissez le jeu sans cheat",17,10,2
texte  <"pour avoir un score",1>,17,11,5

texte "Espace pour quitter",20,17,2

JMP end_affichage_score_final

pas_de_cheat_end :

mov cx,5
mov longueur_points,cl
add longueur_points,13 ; on commence à la colonne 34

mov ax,points
mov points_prov,ax

boucle_compteur_points2 :
push cx
dec longueur_points


mov ax,points_prov
mov cl,10
DIV cl						; points_digit <- points_prov mod 10
mov al,ah
mov ah,0
mov points_digit,ax

mov ax,points_prov
mov cl,10
DIV cl						; points_prov <- points_prov div 10
mov ah,0
mov points_prov,ax	


push di
mov di,[points_digit]
add di,30h ; on convertit points_digit en code ASCII
mov cx,di
pop di
mov ah,13h
mov al,1
mov msg_points,cx
lea bp,msg_points
mov cx,1	; msg_nb_vies_end - offset msg_nb_vies dw
mov dh, 9 ; ligne
mov dl,longueur_points ; colonne
mov bl, 17 ;00111011b
mov bh,0
int 10h

pop cx
loop boucle_compteur_points2

end_affichage_score_final :

boucle_attente_fin_du_jeu :
mov ah,8
int 21h

cmp al,20H
JNE boucle_attente_fin_du_jeu

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*fin

FIN :



texte <"Thanks for playing ",1>,5,11,12

mov att,18
CALL powse

comment /
pusha
mov bx,1
mov cx,1
mov ah,40h 		; fait un zouli bip
lea dx,bip
int 21h
popa
/


        mov     ax, 4c00h
        int     21h
        
;*****************************************************************************************************;
;									*	Processus	*												  ;
;*****************************************************************************************************;

bordures proc



mov ax,0	; ligne d'arrivée
push ax
mov ax, 200 ;ligne de départ
push ax
mov ax, 318 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne


mov ax,0	; colonne d'arrivée
push ax
mov ax, 320 ;colonne de départ
push ax
mov ax, 198 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,0	; ligne d'arrivée
push ax
mov ax, 200 ;ligne de départ
push ax
mov ax, 0 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax


CALL trace_ligne


ret
bordures endp

		trace_ligne proc
		; horizontale=1, verticale=2

; A entrer dans l'ordre :
; - la colonne\ligne d'arrivée
; - la colonne\ligne de départ
; - la ligne\colonne concernée
; - 1 pour horizontale ou 2 pour verticale
; - la couleur de la ligne
pop cx ;osef
mov osef,cx

pop ax  		;couleur ligne
mov ah, 0ch ;écriture pixel
pop bx			;horizontale ou verticale
cmp bx,2
JE vertical

pop dx
pop cx
pop bx
cmp cx,bx
JG end_echange_depart_arrivee1
XCHG cx,bx
end_echange_depart_arrivee1 :
mov tempw,cx

horizontale1 :
dec cx
int 10h
cmp cx,bx
JNE horizontale1

inc dx
mov cx,tempw
horizontale2 :
dec cx
int 10h
cmp cx,bx
JNE horizontale2


JMP finligne


vertical :

pop cx
pop dx
pop bx
cmp dx,bx
JG end_echange_depart_arrivee2
XCHG dx,bx
end_echange_depart_arrivee2 :
mov tempw,dx


verticale1 :
dec dx
int 10h
cmp dx,bx
JNE verticale1

inc cx
mov dx,tempw
verticale2 :
dec dx
int 10h
cmp dx,bx
JNE verticale2


finligne :
mov cx,osef
push cx

ret
trace_ligne endp




coeur proc



erase_coeur macro
push ax	
mov al, 0
mov bl,couleur_yeux
push bx
mov couleur_yeux,0
CALL affichcoeur

pop bx
mov couleur_yeux,bl
pop ax
inc etat_streum
endm


;	pop cx
;	mov osef,cx ; sauvegarde de l'adresse de l'instruction suivant l'appel du processus coeur

mov al,nb_coeur
mov ah,0
mov nb_coeur_prov,ax

mov bp, sp
pop_coor :

dec nb_coeur_prov
	
mov ax,nb_coeur_prov
mul nb_parametres_coeur ;(défini à 6*2) -> multiplie al (=nb_coeur_prov) par 12
mov ad_pile, ax

add bp,ad_pile ; on ajoute à bp ad_pile pour arriver à la bonne adresse
mov dx, ss:[bp+2] ; on lit les adresses ligne-colonne des coeurs directement dans la pile 
mov cx, ss:[bp+4]
mov ax, ss:[bp+6]; couleur de départ dans AL
sub bp,ad_pile ; on n'oublie pas de rendre sa valeur normale à bp 

mov etat_streum,0

mov bl,6

CALL affichcoeur ; affichage du premier coeur

mov bh, etat_streum
mov bx,ss:[bp+12] ; etat_streum

cmp nb_coeur_prov, 0
JNE  pop_coor				; affichage de tous les coeurs



;comment /
;***********


mov ah,8
int 21h

bougeageetc :


mov al, nb_coeur
mov ah,0
mov nb_coeur_prov,ax			;RAZ nb_coeur_prov


CALL attente

suite :

dec nb_coeur_prov
	
mov ax,nb_coeur_prov
mul nb_parametres_coeur ;(défini à 6*2) -> multiplie al (=nb_coeur_prov) par 12
mov ad_pile, ax


add bp,ad_pile
mov ax, ss:[bp+8] ; on lit la direction dans la pile
mov direction,ax

mov ax, ss:[bp+10] ; 
mov vitesse, ax

mov dx, ss:[bp+2] ; position : ligne
mov cx, ss:[bp+4] ; position : colonne
mov ax, ss:[bp+6] ; couleur


mov bx, ss:[bp+12] ; etat_streum
mov etat_streum,bh

CALL bouge_coeur ; on bouge de 1



mov ss:[bp+2],dx ; on range les nouvelles coordonnées + couleur du coeur dans la pile
mov ss:[bp+4],cx
mov ss:[bp+6],bx

mov bh,etat_streum
mov ss:[bp+12], bx

mov ax,direction
mov ss:[bp+8],ax ; on range la nouvelle direction dans la pile


sub bp,ad_pile ; on n'oublie pas de rendre sa valeur normale à bp 


cmp nb_coeur_prov, 0 ; on recommence avec les autres coeurs
JNE suite

cmp nb_tirs,0
JZ non_tir
CALL bouge_tir
non_tir :


JMP bougeageetc ; une fois qu'un a traité tous les coeurs, on recommence.

bouge_coeur proc


dirhd macro
int 10h
CALL tm
cmp al,6
JE destroy_coeur
cmp al,0
JNE ch_dir_hd	
	
endm
dirbg macro

int 10h
CALL tm
cmp al,6
JE destroy_coeur
cmp al,0
JNE ch_dir_bg	
	
endm

dirhg macro
int 10h
CALL tm
cmp al,6
JE destroy_coeur
cmp al,0
JNE ch_dir_hg	
endm

dirbd macro
int 10h
CALL tm
cmp al,6
JE destroy_coeur
cmp al,0
JNE ch_dir_bd	

endm

dirbgtir macro
vdc
cmp al,5
JE ch_dir_bg	
	
endm
dirhdtir macro
vdc
cmp al,5
JE ch_dir_hd	
	
endm
dirhgtir macro
vdc
cmp al,5
JE ch_dir_hg	
	
endm
dirbdtir macro
vdc
cmp al,5
JE ch_dir_bd	
	
endm

vdc macro ;(verif_destroy_coeur)
int 10h
cmp al,6
JE destroy_coeur
endm


CMP direction,0
JE after_push_coor

erase_coeur


;inc ax ;(fait changer les coeurs de couleur)


CMP direction,1
JE haut_gauche
CMP direction,2
JE haut_droite
CMP direction,3
JE bas_gauche
CMP direction,4
JE bas_droite

;************** bas droite
bas_droite : 

mov bx, vitesse
add cx,bx
add dx,bx

push cx
push dx


cmp ah,1
JNE non_clign1
push ax
mov ax,10
CALL affichcoeur
pop ax
mov ah,0
JMP clign1
non_clign1 :
CALL affichcoeur
clign1 :


mov bx,ax ; transfert de la couleur vers bx

	;********

mov ah,0dH

mov sav_cx,cx
mov sav_dx,dx

add dx,4
sub cx,3
dirhd
inc cx
dirhd
inc cx
dirhd
inc cx
dirhd
inc cx
dirhd
inc cx
dirhd
inc cx
dirhd

inc cx


dec dx
dirbg
dec dx
dirbg
dec dx
dirbg
dec dx
dirbg
dec dx
dirbg
dec dx
dirbg


;;; on vérifie 1 plus loin pour les tirs car ils se déplacent 2 fois plus vite.
inc cx
dirbgtir
inc dx
dirbgtir
inc dx
dirbgtir
inc dx
dirbgtir
inc dx
dirbgtir
inc dx
dirbgtir
inc dx
dirbgtir

inc dx
dec cx
dirhdtir
dec cx
dirhdtir
dec cx
dirhdtir
dec cx
dirhdtir
dec cx
dirhdtir
dec cx
dirhdtir
dec cx
dirhdtir

sub cx,2
sub dx,2
vdc
dec dx
vdc
dec dx
vdc
dec dx
vdc
dec dx
vdc
dec dx
vdc

dec dx
inc cx
vdc
inc cx
vdc
inc cx
vdc
inc cx
vdc
inc cx
vdc
inc cx
vdc
inc cx
vdc

dec dx
vdc
dec cx
vdc
dec cx
vdc
dec cx
vdc
dec cx
vdc
dec cx
vdc

sub cx,3
add dx,3
vdc
inc dx
vdc
inc dx
vdc
inc dx
vdc
inc dx
vdc
inc dx
vdc


JMP push_coor

;*********** haut droite

haut_droite : 

mov bx, vitesse
add cx,bx
sub dx,bx

push cx
push dx


cmp ah,1
JNE non_clign2
push ax
mov ax,10
CALL affichcoeur
pop ax
mov ah,0
JMP clign2
non_clign2 :
CALL affichcoeur
clign2 :
mov bx,ax 
	;********

mov ah,0dH

mov sav_cx,cx
mov sav_dx,dx

sub dx,2
add cx,4
cmp al,0
JE gbfd
gbfd :
dec dx
sub cx,7
dirbd
inc cx
dirbd
inc cx
dirbd
inc cx
dirbd
inc cx
dirbd
inc cx
dirbd
inc cx
dirbd

inc cx

inc dx
dirhg
inc dx
dirhg
inc dx
dirhg
inc dx
dirhg
inc dx
dirhg
inc dx
dirhg

; vérfis tirs
inc cx
dirhgtir
dec dx
dirhgtir
dec dx
dirhgtir
dec dx
dirhgtir
dec dx
dirhgtir
dec dx
dirhgtir
dec dx
dirhgtir

dec dx
dec cx
dirbdtir
dec cx
dirbdtir
dec cx
dirbdtir
dec cx
dirbdtir
dec cx
dirbdtir
dec cx
dirbdtir
dec cx
dirbdtir

sub cx,2
add dx,2
vdc
inc dx
vdc
inc dx
vdc
inc dx
vdc
inc dx
vdc
inc dx
vdc

inc dx
inc cx
vdc
inc cx
vdc
inc cx
vdc
inc cx
vdc
inc cx
vdc
inc cx
vdc
inc cx
vdc

dec dx
vdc
dec cx
vdc
dec cx
vdc
dec cx
vdc
dec cx
vdc
dec cx
vdc

sub cx,3
sub dx,3
vdc
dec dx
vdc
dec dx
vdc
dec dx
vdc
dec dx
vdc
dec dx
vdc


JMP push_coor

;********** bas gauche

bas_gauche : 

mov bx, vitesse
sub cx,bx
add dx,bx

push cx
push dx

cmp ah,1
JNE non_clign3
push ax
mov ax,10
CALL affichcoeur
pop ax
mov ah,0
JMP clign3
non_clign3 :
CALL affichcoeur
clign3 :

mov bx,ax 
	;********
mov ah,0dH

mov sav_cx,cx
mov sav_dx,dx

add dx,4
add cx,3
dirhg
dec cx
dirhg
dec cx
dirhg
dec cx
dirhg
dec cx
dirhg
dec cx
dirhg
dec cx
dirhg

dec cx


dec dx
dirbd
dec dx
dirbd
dec dx
dirbd
dec dx
dirbd
dec dx
dirbd
dec dx
dirbd


;;; on vérifie 1 plus loin pour les tirs car ils se déplacent 2 fois plus vite.
dec cx
dirbdtir
inc dx
dirbdtir
inc dx
dirbdtir
inc dx
dirbdtir
inc dx
dirbdtir
inc dx
dirbdtir
inc dx
dirbdtir

inc dx
inc cx
dirhgtir
inc cx
dirhgtir
inc cx
dirhgtir
inc cx
dirhgtir
inc cx
dirhgtir
inc cx
dirhgtir
inc cx
dirhgtir

add cx,2
sub dx,2
vdc
dec dx
vdc
dec dx
vdc
dec dx
vdc
dec dx
vdc
dec dx
vdc

dec dx
dec cx
vdc
dec cx
vdc
dec cx
vdc
dec cx
vdc
dec cx
vdc
dec cx
vdc
dec cx
vdc

dec dx
vdc
inc cx
vdc
inc cx
vdc
inc cx
vdc
inc cx
vdc
inc cx
vdc

add cx,3
add dx,3
vdc
inc dx
vdc
inc dx
vdc
inc dx
vdc
inc dx
vdc
inc dx
vdc


JMP push_coor

;********* haut gauche

haut_gauche : 

mov bx, vitesse
sub cx,bx
sub dx,bx

push cx
push dx

cmp ah,1
JNE non_clign4
push ax
mov ax,10
CALL affichcoeur
pop ax
mov ah,0
JMP clign4
non_clign4 :
CALL affichcoeur
clign4 :

mov bx,ax 
	;********
mov ah,0dH

mov sav_cx,cx
mov sav_dx,dx 

sub dx,3
add cx,3
dirbg
dec cx
dirbg
dec cx
dirbg
dec cx
dirbg
dec cx
dirbg
dec cx
dirbg
dec cx
dirbg

dec cx

inc dx
dirhd
inc dx
dirhd
inc dx
dirhd
inc dx
dirhd
inc dx
dirhd
inc dx
dirhd

; vérfis tirs
dec cx
dirhdtir
dec dx
dirhdtir
dec dx
dirhdtir
dec dx
dirhdtir
dec dx
dirhdtir
dec dx
dirhdtir
dec dx
dirhdtir

dec dx
inc cx
dirbgtir
inc cx
dirbgtir
inc cx
dirbgtir
inc cx
dirbgtir
inc cx
dirbgtir
inc cx
dirbgtir
inc cx
dirbgtir

add cx,2
add dx,2
vdc
inc dx
vdc
inc dx
vdc
inc dx
vdc
inc dx
vdc
inc dx
vdc

inc dx
dec cx
vdc
dec cx
vdc
dec cx
vdc
dec cx
vdc
dec cx
vdc
dec cx
vdc
dec cx
vdc

inc dx
vdc
inc cx
vdc
inc cx
vdc
inc cx
vdc
inc cx
vdc
inc cx
vdc

add cx,3
sub dx,3
vdc
dec dx
vdc
dec dx
vdc
dec dx
vdc
dec dx
vdc
dec dx
vdc


JMP push_coor

;********************* ch_dir :
ch_dir_hg :


mov cx,sav_cx
mov dx,sav_dx
sub cx,4
mov ah,0dh
mov bh,1
int 10h
cmp al,0
JZ chdir1_test2
mov direction, 2
JMP clignotement
chdir1_test2 :
add cx,4
sub dx,3
int 10h
cmp al,0
JZ chdir1
mov direction,3
JMP clignotement
chdir1 :
mov direction, 1
JMP clignotement


ch_dir_hd :
mov cx,sav_cx
mov dx,sav_dx
sub dx,3
mov ah,0dh
mov bh,1
int 10h
cmp al,0
JZ chdir2_test2
mov direction, 4
JMP clignotement ; empêche les ennemis de passer à travers les murs dans les coins
chdir2_test2 :
add dx,3
add cx,4
int 10h
cmp al,0
JZ chdir2
mov direction,1
JMP clignotement		; dans cette partie on ne regarde qu'un autre pixel pour savoir si on est 
chdir2 :				; dans un coin ; cette partie pourrait donc être améliorée en vérifiant
mov direction, 2 		; tous les pixels (pour gérer les petits coins, les coins "troués" etc)
JMP clignotement

ch_dir_bg :

mov cx,sav_cx
mov dx,sav_dx
sub cx,4
mov ah,0dh
mov bh,1
int 10h
cmp al,0
JZ chdir3_test2
mov direction, 4
JMP clignotement
chdir3_test2 :
add cx,4
add dx,4
int 10h
cmp al,0
JZ chdir3
mov direction,1
JMP clignotement
chdir3 :
mov direction, 3
JMP clignotement


ch_dir_bd :

mov cx,sav_cx
mov dx,sav_dx
add dx,4
mov ah,0dh
mov bh,1
int 10h
cmp al,0
JZ chdir4_test2
mov direction, 2
JMP clignotement
chdir4_test2 :
sub dx,4
add cx,4
int 10h
cmp al,0
JZ chdir4
mov direction,3
JMP clignotement
chdir4 :
mov direction, 4
;JMP clignotement

clignotement :
;mov bx,10
;inc bx
mov bh,1 ; si on rebondit on place bh à 1 pour clignoter la prochaine fois
JMP push_coor


destroy_coeur :
pop dx
pop cx
dec nb_ennemis_restants
erase_coeur
mov direction,0
add points,20
CALL affiche_points

pusha
inc etat_msg_destroy_coeur
cmp etat_msg_destroy_coeur,4
JNE end_raz_msg_destroy_coeur
mov etat_msg_destroy_coeur,0
end_raz_msg_destroy_coeur :

cmp etat_msg_destroy_coeur,0
JNE mess1
texte "Pim !        ",couleur_msg_destroy_coeur,1,18
JMP fin_mess
mess1 :
cmp etat_msg_destroy_coeur,1
JNE mess2
texte "Bam !        ",couleur_msg_destroy_coeur,1,18
JMP fin_mess
mess2 :
cmp etat_msg_destroy_coeur,2
JNE mess3
texte "Poum !       ",couleur_msg_destroy_coeur,1,18
JMP fin_mess
mess3 :
texte "Bang !       ",couleur_msg_destroy_coeur,1,18
JMP fin_mess

fin_mess :


mov bl, couleur_msg_destroy_coeur ;00111011b
inc bl
mov  couleur_msg_destroy_coeur,bl

popa

inc nb_coeurs_detruits

mov ax,nb_coeurs_detruits
mov bl,10
div bl
cmp ah,0
JNE vie_supp_end


cmp vies_inf_on,1
JE mode_vies_infinies1
inc nb_vies
mode_vies_infinies1 :
CALL affiche_vies


texte "+1 up !!!    ",5,1,18

mov cx,220
mov dx,11
mov ah,0ch
Call haut


vie_supp_end :


JMP after_push_coor


push_coor :
pop dx
pop cx

after_push_coor :

ret


bouge_coeur endp
;/

ret 10
coeur endp

tm proc ;(test_mort)
cmp death_ON,0
JZ fin_tm
cmp al,couleur_vaisseau
JE death
cmp al,couleur_vaisseau_ext
JE death
fin_tm :
ret
tm endp


;/

affichcoeur proc

; mettre la couleur dans al avant lancement,
; la colonne de départ dans CX
; et la ligne de départ dans DX


push ax
mov ah, 0ch
push bx
mov bl, couleur_yeux


add cx,2
inc dx
int 10h
	
inc cx
int 10h

inc dx
int 10h

inc dx
int 10h

sub cx,2

cmp etat_streum,1
JNE etat2
int 10h

dec dx
dec cx
int 10h

dec cx
inc dx
int 10h

sub cx,2


JMP suite_etat

etat2 :
dec dx
int 10h

inc dx
dec cx
int 10h

dec dx
dec cx
int 10h

sub cx,2
inc dx

mov etat_streum,0

suite_etat :
int 10h

dec dx
int 10h

;dec dx
;int 10h

dec dx
int 10h

inc cx
int 10h

sub dx,2
int 10h

dec cx
dec dx
int 10h

add cx,2
int 10h

add cx,2
int 10h

add cx,2
int 10h

dec cx
inc dx
int 10h

dec cx
inc dx
mov al,bl
int 10h

sub cx,2
int 10h

inc bl
mov couleur_yeux,bl

inc cx
pop bx
pop ax

ret	 
affichcoeur endp


		attente proc

cmp nb_ennemis_restants,0
JE next_level

comment /
push ax ; sauvegardes
push bx
push cx
push dx
/
;;;
mov sav1,ax
mov sav2,bx
mov sav3,cx
mov sav4,dx
;;;
mov att,1h

CALL powse

CALL erase_personnage ; **********A MODIFIER***********
CALL personnage ; à mettre uniquement si on veut que le vaisseau change tout de suite de couleur quand on appuie sur &
					; cf ici pour le mode invisible
CALL barre_du_haut

;;;;;;;;;;;;
comment / 
cmp elan,4
JNE hop
mov ah,0Ch			; vide le buffer clavier (à enlever ou non)
mov al,0
int 21h
hop : 
;;;;;;;;;;;
cmp elan,0
JZ comparaisons
dec elan
JMP dir_mvt_elan
/

CALL verif_munitions
CALL verif_bombes

comparaisons :
mov ah, 6h
mov dl,0ffh
int 21h
;;;;
;mov ah,0
;int 16h
;;;;
cmp al,1BH					; échap pour quitter à n'importe quel moment (y)
JE FIN
cmp al,72H
JE restart_sans_perte_de_vie
cmp al,20h
JE activ_pers
;cmp al,61H
;JE dec_coul
;cmp al,7AH
;JE inc_coul
;comment /
	mov dx,ligne_pers 
	mov cx,colonne_pers	
	mov ah,0dH
cmp al,69H
JE ch_dir_h
cmp al,38h
JE ch_dir_h
cmp al,6Ah
JE ch_dir_g
cmp al,34h
JE ch_dir_g
cmp al,6Bh
JE ch_dir_b
cmp al,35h
JE ch_dir_b
cmp al,6Ch
JE ch_dir_d
cmp al,36H
JE ch_dir_d
cmp al,65H
JE tir
cmp al,66H
JE tir
cmp al,73H
JE tir
cmp al,70H
JE pause2
cmp al,64H
JE tir
cmp al,74H
JE verif_allowed
cmp al,6DH
JE ret_menu

JMP cmp_mvt

ret_menu : JMP retour_menu

verif_allowed :
cmp nl_allowed,1
JNE cmp_mvt
mov munitions_canon,0
mov stock_bombes,0
JMP next_level

cmp_mvt :
cmp mvt_pers,0
JZ rien

cmp_dirs :
	mov dx,ligne_pers 
	mov cx,colonne_pers	
	mov ah,0dH
	cmp dir_pers,1
		JE mvt_haut
	cmp dir_pers,4
		JE mvt_gauche
	cmp dir_pers,3
		JE mvt_bas
	cmp dir_pers,2
		JE mvt_droite

JMP rien

activ_pers :
cmp mvt_pers,0 ;si on est arrêté, on bouge
JZ activation
mov mvt_pers,0		; si on bouge, on s'arrête
JMP rien

activation :
mov mvt_pers,1 
JMP cmp_dirs


ch_dir_h :
mov mvt_pers,1 
JMP mvt_haut

ch_dir_g :
mov mvt_pers,1 
JMP mvt_gauche

ch_dir_d :
mov mvt_pers,1 
JMP mvt_droite

ch_dir_b :
mov mvt_pers,1 
JMP mvt_bas

;;;;;
comment /
dir_mvt_elan :
	mov dx,ligne_pers 
	mov cx,colonne_pers	
	mov ah,0dH
	cmp dir_pers,1
		JE mvt_haut
	cmp dir_pers,4
		JE mvt_gauche
	cmp dir_pers,3
		JE mvt_bas
	cmp dir_pers,2
		JE mvt_droite

mvt :
cmp etat_reacteurs,0 ; si on n'était pas en train de bouger, on donne de l'élan
JNZ dir_mvt
mov elan,10 ;;;;; modifiable

dir_mvt :
	cmp al,69H
		JE mvt_haut
	cmp al,6Ah
		JE mvt_gauche
	cmp al,6Bh
		JE mvt_bas
	cmp al,6Ch
		JE mvt_droite
		
	JMP rien
/
ta macro ; (test_avance)
LOCAL suit	
	int 10h
	cmp al,couleur_vaisseau
	JE suit
	cmp al,couleur_vaisseau_ext
	JE suit
	cmp al,0
	JNE rien
	suit :	
	
	
endm

mvt_haut :
	add cx,3
	dec dx
	ta
	sub cx,6
	ta	
	add cx,2
	sub dx,2
	ta
	add cx,2
	ta
	dec cx
	dec dx				; on lit la couleur du pixel au dessus du vaisseau, et s'il n'est pas
	ta					; noir, on ne fait rien.
	CALL erase_personnage
	dec ligne_pers
	cmp vitesse_doublee,0
	JZ end_vitesse_doublee_haut
	dec ligne_pers
	end_vitesse_doublee_haut :
	mov dir_pers, 1
	JMP affich_personnage
mvt_gauche :
dec cx ;modif gauche
	add dx,3
	dec cx
	ta
	sub dx,6
	ta	
	add dx,2
	sub cx,2
	ta
	add dx,2
	ta
	inc dx
	dec cx
	ta
	CALL erase_personnage
	dec colonne_pers
	cmp vitesse_doublee,0
	JZ end_vitesse_doublee_gauche
	dec colonne_pers
	end_vitesse_doublee_gauche :
	mov dir_pers, 4
	JMP affich_personnage
mvt_droite :
	add dx,3
	inc cx
	ta
	sub dx,6
	ta	
	add dx,2
	add cx,2
	ta
	add dx,2
	ta
	dec dx
	inc cx
	ta
	CALL erase_personnage
	inc colonne_pers
	cmp vitesse_doublee,0
	JZ end_vitesse_doublee_droite
	inc colonne_pers
	end_vitesse_doublee_droite :
	mov dir_pers, 2
	JMP affich_personnage
mvt_bas : 
	add cx,3
	add dx,2
	ta
	sub cx,6
	ta	
	add cx,2
	add dx,2
	ta
	add cx,2
	ta
	inc dx
	dec cx
	ta
	CALL erase_personnage
	inc ligne_pers
	cmp vitesse_doublee,0
	JZ end_vitesse_doublee_bas
	inc ligne_pers
	end_vitesse_doublee_bas :
	mov dir_pers, 3

affich_personnage :
mov etat_reacteurs,1
CALL personnage

;JMP comparaisons  				; à laisser ou non (change la maniabilité)
JMP rien

dec_coul :
dec couleur_vaisseau
JZ dec_coul
JMP comparaisons

inc_coul :
inc couleur_vaisseau
JZ inc_coul
JMP comparaisons

;*********************************		*tirs :
tir :
;;;;;;;;;;;;;;;;;;;;;;;;; TESTS
pop bx		;;	Attention : on n'oublie pas qu'au sommet de la pile se trouve l'adresse
mov osef,bx		;; de la prochaine instruction, nécessaire au ret. on la sort donc...

cmp premier_tir,1
JNE tirs_suivants
mov premier_tir,0

mov di,sp


tirs_suivants :
comment /
cmp sp,0FF00h
mov sp_depassee,1
JNA suite_tir

mov savsp,sp
mov sp,di

suite_tir :
/
comment /
cmp nb_tirs,256
JNE frgdf
dec nb_tirs

mov bp,sp
mov dx, ss:[bp+2050]
mov cx, ss:[bp+2052]
mov al,0
mov ah, 0cH
int 10h
/
;frgdf :
;cmp nb_tirs, 255 ;256
;JNE pas_raz_tir
;mov sp,di
;mov nb_tirs,0

;pas_raz_tir :
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mov cx,colonne_pers
mov dx,ligne_pers

mov bool_bombe,0
cmp al,65H
JE tir_milieu
cmp al,66H
JE tir_canon_droit
cmp al,73H
JE tir_canon_gauche
mov bool_bombe,4
cmp al,64H
JE tir_bombe

tir_canon_droit :


	mov bh,5 	;on place la couleur dans bh (on a besoin de al)
	cmp dir_pers,1
	JE tir_haut_d
	cmp dir_pers,2
	JE tir_droite_d
	cmp dir_pers,3
	JE tir_bas_d
	cmp dir_pers,4
	JE tir_gauche_d

	tir_haut_d :
		add cx,3
		sub dx,2
		JMP fin_tir
	tir_droite_d :
		add cx,3
		add dx,3
		JMP fin_tir	
	tir_bas_d :
		add dx,3
		sub cx,3
		JMP fin_tir
	tir_gauche_d :
		sub cx,3
		sub dx,3
		JMP fin_tir

tir_canon_gauche :


	mov bh,5 	;on place la couleur dans bh (on a besoin de al)
	cmp dir_pers,1
	JE tir_haut_g
	cmp dir_pers,2
	JE tir_droite_g
	cmp dir_pers,3
	JE tir_bas_g
	cmp dir_pers,4
	JE tir_gauche_g

	tir_haut_g :
		sub cx,3
		sub dx,3
		JMP fin_tir
	tir_droite_g :
		add cx,3
		sub dx,3
		JMP fin_tir	
	tir_bas_g :
		add dx,3
		add cx,3
		JMP fin_tir
	tir_gauche_g :
		sub cx,3
		add dx,3
		JMP fin_tir
		
tir_bombe :

;cmp munit_infini,1
;JE bombes_dispo ;si le cheat munitions infinies est activé, on ne regarde pas le stock de bombes

cmp stock_bombes,0
JNE bombes_dispo



texte "no bomb stock",7,1,18

JMP fin_fin_tir

bombes_dispo :
	cmp munit_infini,1
	JE pas_dec_bombes
dec stock_bombes
	pas_dec_bombes :
cmp points,0
JZ end_dec_points_b
dec points
end_dec_points_b :

	cmp dir_pers,1
	JE tir_haut_bombe
	cmp dir_pers,2
	JE tir_droite_bombe
	cmp dir_pers,3
	JE tir_bas_bombe
	cmp dir_pers,4
	JE tir_gauche_bombe
	
	tir_haut_bombe :
		;sub cx,3
		sub dx,8
		JMP fin_tir
	tir_droite_bombe :
		add cx,7
		;sub dx,3
		JMP fin_tir
	tir_bas_bombe :
		add dx,8
		;add cx,3
		JMP fin_tir
	tir_gauche_bombe :
		sub cx,8
		;add dx,3
		JMP fin_tir



tir_milieu :

;CALL bip ;ù


cmp munitions_canon,0
JZ plus_de_munitions


mov bh,6

	cmp munit_infini,1
	JE pas_dec_munits
dec munitions_canon
	pas_dec_munits :
cmp points,0
JZ end_dec_points
dec points
end_dec_points :
cmp munitions_canon,0
JNZ munitions

texte "last munition",4,1,18


JMP munitions
plus_de_munitions :
mov bh,5
munitions :
cmp dir_pers,1
JE tir_haut
cmp dir_pers,2
JE tir_droite
cmp dir_pers,3
JE tir_bas
cmp dir_pers,4
JE tir_gauche

tir_haut :
	sub dx,5
	JMP fin_tir
tir_droite :
	add cx,5
	JMP fin_tir	
tir_bas :
	add dx,6
	JMP fin_tir
tir_gauche :
	sub cx,6
	JMP fin_tir


fin_tir :

mov ah, 0dh ; lecture pixel
int 10h
cmp al, couleur_murs		; si il y a un mur ou un item, on tire pas...
JE fin_fin_tir 
cmp al, couleur_bombes_ext
JE fin_fin_tir 
cmp al, couleur_bombes_int
JE fin_fin_tir 
cmp al, couleur_munits_int
JE fin_fin_tir 
cmp al, couleur_munits_int2
JE fin_fin_tir 
cmp al, couleur_munits_corps
JE fin_fin_tir 
cmp al, couleur_munits_coins
JE fin_fin_tir 


mov ah,0ch
mov al,bh
	int 10h	
	mov bl,dir_pers
	add bl,bool_bombe
	push bx
	push ax
	push cx
	push dx

	
;	cmp nb_tirs,255		;;;;
;	JE fin_fin_tir_255 		;;;
	inc nb_tirs
	
;	JMP fin_fin_tir
	
;	fin_fin_tir_255 :

comment /
	mov sav_test,bp
	mov bp,sp
mov dx, ss:[bp+2040];2042
mov cx, ss:[bp+2042];2044			; tests pour essayer d'effacer les premiers tirs.
mov al,14
mov ah, 0cH
mov bh,1
int 10h
mov bp,sav_test
/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TESTS
comment /
	cmp sp_depassee,1
	JNE fin_fin_tir
	mov sp,savsp
	;add bp,8
fin_fin_tir :
/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fin_fin_tir :

	mov bx,osef	;; 	... et on la remet au dessus de la pile.
	push bx	;;

JMP cmp_mvt
;/
;

pause2 :
texte "    pause    ",4,1,18


mov ah, 6h
mov dl,0ffh
int 21h
cmp al,1BH
JE fin
cmp al,70h
JNE pause2

efface_barre

rien :
;;; TESTS<
;mov ah,05h
;mov cx,3Fh
;int 16h
;;; TESTS>
comment /
pop dx
pop cx

pop bx
pop ax
/

mov ax,sav1
mov bx,sav2
mov cx,sav3
mov dx,sav4

;
;mov ah,0Ch
;mov al,0					; 	vide le buffer clavier
;int 21h
;
ret
attente endp

;********************************** macros utilisées pour l'affichage du personnage

powse proc
pusha
;comment /	
cmp dosbox_mode_on,1
JE pause_dosbox


MOV AH, 00H
INT 1AH 		; lit l'heure et la met dans DX
add att, DX		; on ajoute l'heure à att
cmp mode_speed_on,1
JE no_limit
boucleattente :
int 1Ah
CMP DX, att
JB boucleattente ; on mouline tant que l'heure n'est pas égale à l'heure + att
;
no_limit :
JMP fin_pause


;/
pause_dosbox :	;DOSBox autorise l'int 15h fonction 86h (contrairement à Windows XP) Merci DOSBox !
;comment /
mov ah,86h
mov cx,0
mov dx,50000
int 15h
;/

fin_pause :
popa
	ret

powse endp

droite macro

mov	al,couleur_vaisseau_int
int 10h
inc cx
int 10h
inc cx
int 10h
mov al,couleur_vaisseau
inc cx
int 10h
dec dx
dec cx
int 10h
dec cx
int 10h
dec cx
int 10h
add dx,2
int 10h
inc cx
int 10h
inc cx
int 10h
sub cx,3
inc dx
int 10h
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h
dec dx
dec cx
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
dec cx
sub dx,2
int 10h
sub dx,2
int 10h

mov al,couleur_vaisseau_ext
add cx,2
sub dx,2
int 10h
inc cx
int 10h
add dx,6
int 10h
dec cx
int 10h

endm

bas macro

mov	al,couleur_vaisseau_int
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
mov al,couleur_vaisseau
inc dx
int 10h
dec cx
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h
add cx,2
int 10h
inc dx
int 10h
inc dx
int 10h
sub dx,3
inc cx
int 10h
dec cx
int 10h
dec cx
int 10h
dec cx
int 10h
dec cx
int 10h
dec cx
dec dx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
dec dx
sub cx,2
int 10h
sub cx,2
int 10h

mov al,couleur_vaisseau_ext
sub cx,2
add dx,2
int 10h
inc dx
int 10h
add cx,6
int 10h
dec dx
int 10h

	
endm

gauche macro

mov	al,couleur_vaisseau_int
int 10h
dec cx
int 10h
dec cx
int 10h
mov al,couleur_vaisseau
dec cx
int 10h
inc dx
inc cx
int 10h
inc cx
int 10h

inc cx
int 10h
sub dx,2
int 10h
dec cx
int 10h
dec cx
int 10h
add cx,3
dec dx
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx
inc cx
int 10h
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h
inc cx
add dx,2
int 10h
add dx,2
int 10h
	
mov al,couleur_vaisseau_ext
sub cx,2
sub dx,4
int 10h
dec cx
int 10h
add dx,6
int 10h
inc cx
int 10h
	
endm

;********************************** personnage (affichage et déplacement)

personnage proc

push ax
push cx
push dx

mov ah,0Ch	
mov cx,colonne_pers
mov dx,ligne_pers

cmp dir_pers,1
JE affich_haut
cmp dir_pers,2
JE affich_droite
cmp dir_pers,3
JE affich_bas
cmp dir_pers,4
JE affich_gauche

JMP retour_personnage

affich_haut :
	Call haut
	cmp etat_reacteurs,0
	JZ retour_personnage
	
	add dx,3
	sub cx,2
	
	mov ah,0dh
	int 10h
	cmp al,0
	JNE retour_personnage
	mov ah,0ch
	mov al,14
	int 10h
	sub cx,2
	mov ah,0dh
	int 10h
	cmp al,0
	JNE retour_personnage
	mov ah,0ch
	mov al,14
	int 10h
	mov etat_reacteurs,1
	JMP retour_personnage
	
affich_droite :
	droite
	cmp etat_reacteurs,0
	JZ retour_personnage
	sub cx,3
	sub dx,2
	mov ah,0dh
	int 10h
	cmp al,0
	JNE retour_personnage
	mov ah,0ch
	mov al,14
	int 10h
	sub dx,2
	mov ah,0dh
	int 10h
	cmp al,0
	JNE retour_personnage
	mov ah,0ch
	mov al,14
	int 10h
	mov etat_reacteurs,1
	JMP retour_personnage

affich_bas :
	bas
	cmp etat_reacteurs,0
	JZ retour_personnage
	sub dx,3
	sub cx,2
	mov ah,0dh
	int 10h
	cmp al,0
	JNE retour_personnage
	mov ah,0ch
	mov al,14
	int 10h
	sub cx,2
	mov ah,0dh
	int 10h
	cmp al,0
	JNE retour_personnage
	mov ah,0ch
	mov al,14
	int 10h
	mov etat_reacteurs,1
	JMP retour_personnage
	
affich_gauche :
dec cx ;modif gauche
	gauche
	cmp etat_reacteurs,0
	JZ retour_personnage
	add cx,3
	sub dx,2
	mov ah,0dh
	int 10h
	cmp al,0
	JNE retour_personnage
	mov ah,0ch
	mov al,14
	int 10h
	sub dx,2
	mov ah,0dh
	int 10h
	cmp al,0
	JNE retour_personnage
	mov ah,0ch
	mov al,14
	int 10h
	mov etat_reacteurs,1
	JMP retour_personnage

retour_personnage :

pop dx
pop cx
pop ax

ret
	
personnage endp

erase_personnage proc
push ax
push cx
push dx

mov bh,couleur_vaisseau_ext
mov temp,bh
mov bh,couleur_vaisseau			;on sauve les couleurs de base
mov bl,couleur_vaisseau_int

mov couleur_vaisseau,0			; on met 0 à la place
mov couleur_vaisseau_int,0
mov couleur_vaisseau_ext,0


mov ah,0Ch	
mov cx,colonne_pers
mov dx,ligne_pers


cmp dir_pers,1
JE erase_haut
cmp dir_pers,2
JE erase_droite
cmp dir_pers,3
JE erase_bas
cmp dir_pers,4
JE erase_gauche

JMP retour_erase_personnage

erase_haut :
	Call haut
	cmp etat_reacteurs,0
	JZ retour_erase_personnage
	mov al,0
	add dx,3
	sub cx,2
	int 10h
	sub cx,2
	int 10h
	mov etat_reacteurs,0
	JMP retour_erase_personnage
	
erase_droite :
	droite
	cmp etat_reacteurs,0
	JZ retour_erase_personnage
	mov al,0
	sub cx,3
	sub dx,2
	int 10h
	sub dx,2
	int 10h
	mov etat_reacteurs,0
	JMP retour_erase_personnage

erase_bas :
	bas
	cmp etat_reacteurs,0
	JZ retour_erase_personnage
	mov al,0
	sub dx,3
	sub cx,2
	int 10h
	sub cx,2
	int 10h
	mov etat_reacteurs,0
	JMP retour_erase_personnage
	
erase_gauche :
dec cx ;modif gauche
	gauche
	cmp etat_reacteurs,0
	JZ retour_erase_personnage
	mov al,0
	add cx,3
	sub dx,2
	int 10h
	sub dx,2
	int 10h
	mov etat_reacteurs,0
	JMP retour_erase_personnage

retour_erase_personnage :

mov couleur_vaisseau,bh
mov couleur_vaisseau_int,bl
mov bh,temp
mov couleur_vaisseau_ext,bh

pop dx
pop cx
pop ax

ret
erase_personnage endp



bouge_tir proc
	
mov osef,bp	


mov ax,nb_tirs
mov nb_tir_prov,ax

mov bp, sp
pop_coor_tir :

dec nb_tir_prov
	
mov ax,nb_tir_prov
mul nb_parametres_tir ;(défini à 4*2) -> multiplie al (=nb_coeur_prov) par 8
mov ad_pile, ax

add bp,ad_pile ; on ajoute à di ad_pile pour arriver à la bonne adresse
mov dx, ss:[bp+2] ; on lit les adresses ligne-colonne des tirs directement dans la pile 
mov cx, ss:[bp+4]

mov bx, ss:[bp+8];direction du tir

	cmp bl,0		; si le tir a pour direction 0, on ne fait rien
	JZ apres_bouge_tir
	

mov ah,0ch			; on efface le tir précédent
mov al,0
int 10h



mov ah,0dh ;(lecture pixel)

cmp bl,9
JE animboom1
cmp bl,10
JE animboomsuite
cmp bl,11
JE animboom2
cmp bl,12
JE animboomsuite
cmp bl,13
JE animboom3
cmp bl,14
JE animboomsuite
cmp bl,15
JE animboom4
cmp bl,16
JE animboomsuite
cmp bl,17
JE animboomsuite
cmp bl,18
JE animboomsuite
cmp bl,19
JE finboom

	cmp bl,1
	JE th
	cmp bl,2
	JE td
	cmp bl,3
	JE tb
	cmp bl,4
	JE tg

pusha	
mov ah,0
mov al,couleur_bombes_int
push ax
mov al,couleur_bombes_ext
push ax

mov couleur_bombes_int,0
mov couleur_bombes_ext,0 ; efface la bombe précédente

CALL bombe

pop ax
mov couleur_bombes_ext,al
pop ax
mov couleur_bombes_int,al
popa

	cmp bl,5
	JE thb
	cmp bl,6
	JE tdb
	cmp bl,7
	JE tbb
	cmp bl,8
	JE tgb	
	
	
th :
sub dx,2
JMP affich_tir
td :
add cx,2
JMP affich_tir
tb :
add dx,2
JMP affich_tir
tg :
sub cx,2
JMP affich_tir

thb :
sub dx,2
JMP affich_tir_b
tdb :
add cx,2
JMP affich_tir_b
tbb :
add dx,2
JMP affich_tir_b
tgb :
sub cx,2
JMP affich_tir_b

affich_tir :
int 10h
comment /
cmp al, couleur_murs		; si le tir arrive à un mur ou un item, on place sa direction à 0
JE annul_tir				; Le tir ne sera alors plus traité.
cmp al, couleur_bombes_ext
JE annul_tir
cmp al, couleur_bombes_int
JE annul_tir
cmp al, couleur_munits_int
JE annul_tir
cmp al, couleur_munits_int2
JE annul_tir
cmp al, couleur_munits_corps
JE annul_tir
cmp al, couleur_munits_coins
JE annul_tir
/
cmp al,0
JNE annul_tir_exc 
JMP affichage_tir
annul_tir_exc :
cmp al,couleur_ennemis
JE affichage_tir		
annul_tir :
mov ss:[bp+8],0
JMP apres_bouge_tir

affich_tir_b :

bom macro
int 10h
cmp al,0		; si la bombe arrive à un mur ou un item, BOOM !
JNE boom				
endm

;mov bh,1
;mov ah,0dh
bom
sub dx,2
bom
add dx,2
add cx,2
bom
inc cx
bom
sub cx,3
add dx,2  ; vérifications intérieures
bom
inc dx
bom
sub cx,2
sub dx,3
bom
dec cx
bom
add cx,3 ; revient au milieu

sub dx,4
bom
add cx,5
add dx,4
bom
sub cx,5
add dx,5		; avant toute chose, on regarde les 4 directions.
bom
sub cx,5
sub dx,5
bom
add cx,6
sub dx,4
bom
inc cx
bom
inc cx
bom
inc cx
bom
inc cx
bom
inc dx
bom
inc dx
bom
inc dx
bom
inc dx
bom
inc dx
bom
inc dx
bom
inc dx
bom
inc dx
bom
inc dx
bom
dec cx
bom
dec cx
bom
dec cx
bom
dec cx
bom
dec cx
bom
dec cx
bom
dec cx
bom
dec cx
bom
dec cx
bom
dec cx
bom
dec dx
bom
dec dx
bom
dec dx
bom
dec dx
bom
dec dx
bom
dec dx
bom
dec dx
bom
dec dx
bom
dec dx
bom
inc cx
bom
inc cx
bom
inc cx
bom
inc cx
bom

inc cx
add dx,4



mov al,couleur_bombes_ext
push ax
mov couleur_bombes_ext,6
CALL bombe
pop ax
mov couleur_bombes_ext,al

JMP rangement_des_coords

boom :
;mov dx, ss:[bp+2] ; on lit les adresses ligne-colonne des tirs directement dans la pile 
;mov cx, ss:[bp+4]
texte "BOOM !!!     ",4,1,18


mov ah,0ch
mov al,6
int 10h

mov ss:[bp+2],dx
mov ss:[bp+4],cx
mov ss:[bp+8],9
JMP apres_bouge_tir

animboom1 :
mov dx, ss:[bp+2] ; on lit les adresses ligne-colonne des tirs directement dans la pile 
mov cx, ss:[bp+4]
mov ah,0ch
mov al,6
int 10h
inc cx
int 10h
dec cx
dec dx
int 10h
dec cx
inc dx
int 10h
inc cx
inc dx
int 10h
mov ax, ss:[bp+8]
inc ax
mov ss:[bp+8],ax
JMP apres_bouge_tir

animboom2 :
mov dx, ss:[bp+2] ; on lit les adresses ligne-colonne des tirs directement dans la pile 
mov cx, ss:[bp+4]
mov ah,0ch
mov al,6
anim2 macro
int 10h
inc cx
int 10h
inc cx
int 10h
sub cx,2
dec dx
int 10h
dec dx
int 10h
dec cx
add dx,2
int 10h
dec cx
int 10h
add cx,2
inc dx
int 10h
inc dx
int 10h
sub dx,2
endm
anim2
mov ax, ss:[bp+8]
inc ax
mov ss:[bp+8],ax
JMP apres_bouge_tir

animboom3 :
mov dx, ss:[bp+2] ; on lit les adresses ligne-colonne des tirs directement dans la pile 
mov cx, ss:[bp+4]
mov ah,0ch
mov al,0
anim2

mov al,6
anim3 macro
sub dx,2
int 10h
inc cx
int 10h
inc cx
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx
dec cx
int 10h
dec cx
int 10h
dec cx
int 10h
dec cx
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h
dec dx
inc cx
int 10h

inc cx
add dx,2
endm
anim3

mov ax, ss:[bp+8]
inc ax
mov ss:[bp+8],ax
JMP apres_bouge_tir


animboom4 :
mov dx, ss:[bp+2] ; on lit les adresses ligne-colonne des tirs directement dans la pile 
mov cx, ss:[bp+4]
mov ah,0ch

mov al,6
anim4 macro
int 10h
inc cx
int 10h
dec dx
int 10h
dec dx
int 10h
inc cx
int 10h
inc dx
int 10h
sub dx,2
int 10h
inc cx
int 10h
inc dx
int 10h
inc cx
dec dx
int 10h
inc cx
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
dec cx
inc dx
int 10h
dec cx
dec dx
int 10h
dec cx
dec dx
int 10h
dec cx
int 10h
dec cx
int 10h
inc cx
inc dx
int 10h
inc cx
int 10h
inc dx
int 10h
inc cx
int 10h
inc dx
int 10h
inc dx
dec cx
int 10h
dec cx
int 10h
dec cx
int 10h
dec cx
int 10h
dec cx
int 10h
dec cx
dec dx
int 10h
inc cx
dec dx
int 10h
inc cx
dec dx
int 10h
dec dx
int 10h
dec cx
int 10h
inc dx
int 10h
dec cx
int 10h
inc dx
int 10h
dec cx
int 10h
dec cx
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h
dec dx
inc cx
int 10h
inc cx
inc dx
int 10h
inc cx
inc dx
int 10h
inc cx
inc dx
int 10h
inc cx
dec dx
int 10h
dec cx
int 10h
dec dx
int 10h
dec cx
int 10h
dec dx
int 10h
dec cx
int 10h
dec dx
int 10h
dec dx
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
inc dx
int 10h

mov al,0
dec cx
int 10h
dec cx
int 10h
dec cx
int 10h
dec cx
int 10h
dec cx
int 10h
inc cx
inc dx
int 10h
inc cx
int 10h
inc cx
int 10h
inc dx
dec cx
int 10h
add cx,4
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx							;C'est beau hein ?
int 10h
inc dx
int 10h
dec cx
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h
inc dx
dec cx
int 10h
add dx,4
int 10h
dec cx
int 10h
dec cx
int 10h
dec cx
int 10h
dec cx
int 10h
inc cx
dec dx
int 10h
inc cx
int 10h
inc cx
int 10h
dec dx
dec cx
int 10h
sub cx,4
int 10h
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h
inc cx
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
dec dx
inc cx
int 10h

add cx,2

endm
anim4

mov ax, ss:[bp+8]
inc ax
mov ss:[bp+8],ax
JMP apres_bouge_tir

animboomsuite :
mov ax, ss:[bp+8]
inc ax
mov ss:[bp+8],ax
JMP apres_bouge_tir

finboom :

mov dx, ss:[bp+2] ; on lit les adresses ligne-colonne des tirs directement dans la pile 
mov cx, ss:[bp+4]
mov ah,0ch

mov al,0
anim4

mov ss:[bp+8],0
JMP apres_bouge_tir

affichage_tir :
mov ax, ss:[bp+6]; couleur de départ dans AL
mov ah,0ch
int 10h

rangement_des_coords :
mov ss:[bp+2],dx ; on remet les nouvelles coordonnées dans la pile.
mov ss:[bp+4],cx


apres_bouge_tir :
sub bp,ad_pile ; on n'oublie pas de rendre sa valeur normale à bp 

cmp nb_tir_prov, 0
JNE  pop_coor_tir

		
mov bp,osef
	
	ret

bouge_tir endp

affiche_points proc	
	
pusha	

cmp cheat_active,0
JE affichage_normal

texte "CHEAT",2,1,34

JMP end_affiche_points

affichage_normal : 

mov ax,points
mov points_prov,ax

mov cx,5
mov longueur_points,cl
add longueur_points,34 ; on commence à la colonne 34

boucle_compteur_points :
push cx
dec longueur_points


mov ax,points_prov
mov cl,10
DIV cl						; points_digit <- points_prov mod 10
mov al,ah
mov ah,0
mov points_digit,ax

mov ax,points_prov
mov cl,10
DIV cl						; points_prov <- points_prov div 10
mov ah,0
mov points_prov,ax	


push di
mov di,[points_digit]
add di,30h ; on convertit points_digit en code ASCII
mov cx,di
pop di
mov ah,13h
mov al,1
mov msg_points,cx
lea bp,msg_points
mov cx,1	; msg_nb_vies_end - offset msg_nb_vies dw
mov dh, 1 ; ligne
mov dl,longueur_points ; colonne
mov bl, 2h ;00111011b
mov bh,0
int 10h

pop cx
loop boucle_compteur_points	

end_affiche_points :

popa
	
	ret

affiche_points endp

affiche_bombes proc	
	
pusha	
mov ax,stock_bombes
mov nb_bombes_prov,ax

mov cx,2
mov longueur_nb_bombes,cl
add longueur_nb_bombes,15 ; on commence à la colonne 15

boucle_compteur_bombes :
push cx
dec longueur_nb_bombes


mov ax,nb_bombes_prov
mov cl,10
DIV cl						; points_digit <- points_prov mod 10
mov al,ah
mov ah,0
mov nb_bombes_digit,ax

mov ax,nb_bombes_prov
mov cl,10
DIV cl						; points_prov <- points_prov div 10
mov ah,0
mov nb_bombes_prov,ax	


push di
mov di,[nb_bombes_digit]
add di,30h ; on convertit points_digit en code ASCII
mov cx,di
pop di
mov ah,13h
mov al,1
mov msg_nb_bombes,cx
lea bp,msg_nb_bombes
mov cx,1	; msg_nb_vies_end - offset msg_nb_vies dw
mov dh, 1 ; ligne
mov dl,longueur_nb_bombes ; colonne
mov bl, couleur_bombes_int ;00111011b
mov bh,0
int 10h

pop cx
loop boucle_compteur_bombes

popa
	
	ret

affiche_bombes endp

affiche_vies proc
	
pusha

mov ax,nb_vies
mov nb_vies_prov,ax

mov cx,2
mov longueur_vie,cl
add longueur_vie,3 ; on commence à la colonne 3

boucle_compteur_vies :
push cx
dec longueur_vie


mov ax,nb_vies_prov
mov cl,10
DIV cl						; nb_vies_digit <- nb_vies_prov mod 10
mov al,ah
mov ah,0
mov nb_vies_digit,ax

mov ax,nb_vies_prov
mov cl,10
DIV cl						; nb_vies_prov <- nb_vies_prov div 10
mov ah,0
mov nb_vies_prov,ax	


push di
mov di,[nb_vies_digit]
add di,30h ; on convertit nb_vie en code ASCII
mov cx,di
pop di
mov ah,13h
mov al,1
mov msg_nb_vies,cx
lea bp,msg_nb_vies
mov cx,1	; msg_nb_vies_end - offset msg_nb_vies dw
mov dh, 1 ; ligne
mov dl,longueur_vie ; colonne
mov bl, 4h ;00111011b
mov bh,0
int 10h

pop cx
loop boucle_compteur_vies

popa
	ret

affiche_vies endp

affiche_munits proc
	
pusha

mov ax,munitions_canon
mov nb_mun_prov,ax

mov cx,3
mov longueur_mun,cl
add longueur_mun,8 ; on commence à la colonne 8

boucle_compteur_mun :
push cx
dec longueur_mun


mov ax,nb_mun_prov
mov cl,10
DIV cl						; nb_vies_digit <- nb_vies_prov mod 10
mov al,ah
mov ah,0
mov nb_mun_digit,ax

mov ax,nb_mun_prov
mov cl,10
DIV cl						; nb_vies_prov <- nb_vies_prov div 10
mov ah,0
mov nb_mun_prov,ax	


push di
mov di,[nb_mun_digit]
add di,30h ; on convertit nb_vie en code ASCII
mov cx,di
pop di
mov ah,13h
mov al,1
mov msg_nb_mun,cx
lea bp,msg_nb_mun
mov cx,1	; msg_nb_vies_end - offset msg_nb_vies dw
mov dh, 1 ; ligne
mov dl,longueur_mun ; colonne
mov bl, couleur_munits_corps ;00111011b
mov bh,0
int 10h

pop cx
loop boucle_compteur_mun

popa
	ret

affiche_munits endp


verif_bombes proc

vb macro
int 10h
cmp al,couleur_vaisseau_ext
JE bombes_up
cmp al,couleur_vaisseau
JE bombes_up	
	
endm

pusha

;;;;


cmp nb_bombes,0
JE bombes_end


mov bp,sp_bombes

mov ax, nb_bombes
mov osef,ax



sub bp,4

boucle_bombes :
dec osef
add bp,4

mov dx, ss:[bp]
mov cx, ss:[bp+2]

cmp dx,0
JE fin_boucle_bombe


mov bh,1
mov ah,0dh
sub dx,4
vb
inc cx
vb
inc cx
vb
inc cx
vb
inc cx
vb
inc cx
vb
inc dx
vb
inc dx
vb
inc dx
vb
inc dx
vb
inc dx
vb
inc dx
vb
inc dx
vb
inc dx
vb
inc dx
vb
dec cx
vb
dec cx
vb
dec cx
vb
dec cx
vb
dec cx
vb
dec cx
vb
dec cx
vb
dec cx
vb
dec cx
vb
dec cx
vb
dec dx
vb
dec dx
vb
dec dx
vb
dec dx
vb
dec dx
vb
dec dx
vb
dec dx
vb
dec dx
vb
dec dx
vb
inc cx
vb
inc cx
vb
inc cx
vb
inc cx
vb

fin_boucle_bombe :

cmp osef,0
JNE boucle_bombes
JMP bombes_end


bombes_up :

	cmp munit_infini,1
	JZ pas_inc_bombes
	
inc stock_bombes

pas_inc_bombes :


mov dx, ss:[bp]
mov cx, ss:[bp+2]

mov ah,0
mov al,couleur_bombes_int
push ax
mov al,couleur_bombes_ext
push ax

mov couleur_bombes_int,0
mov couleur_bombes_ext,0

CALL bombe

pop ax
mov couleur_bombes_ext,al
pop ax
mov couleur_bombes_int,al

mov dx,0
mov ss:[bp],dx


texte "+1 bombe     ",23,1,18


bombes_end :
popa
ret
verif_bombes endp

verif_munitions proc

vm macro
int 10h
cmp al,couleur_vaisseau_ext
JE munitions_up
cmp al,couleur_vaisseau
JE munitions_up	
	
endm

pusha


cmp nb_munits,0
JE munitions_end


mov bp,sp_munits

mov ax, nb_munits
mov osef,ax



sub bp,4

boucle_munitions :
dec osef
add bp,4

mov dx, ss:[bp]
mov cx, ss:[bp+2]

cmp dx,0
JE fin_boucle_munitions

mov bh,1
mov ah,0dh
sub dx,3
vm
inc cx
vm
inc cx
vm
inc cx
vm
inc dx
vm
inc dx
vm
inc dx
vm
inc dx
vm
inc dx
vm
inc dx
vm
dec cx
vm
dec cx
vm
dec cx
vm
dec cx
vm
dec cx
vm
dec cx
vm
dec dx
vm
dec dx
vm
dec dx
vm
dec dx
vm
dec dx
vm
dec dx
vm
inc cx
vm
inc cx
vm

fin_boucle_munitions :

cmp osef,0
JNE boucle_munitions
JMP munitions_end


munitions_up :

	cmp munit_infini,1
	JZ pas_inc_munits
	
add munitions_canon,10

pas_inc_munits :



mov dx, ss:[bp]
mov cx, ss:[bp+2]

mov ah,0
mov al,couleur_munits_int
push ax
mov al,couleur_munits_int2
push ax
mov al,couleur_munits_coins
push ax
mov al,couleur_munits_corps
push ax

mov couleur_munits_int,0
mov couleur_munits_int2,0
mov couleur_munits_coins,0
mov couleur_munits_corps,0

CALL munits

pop ax
mov couleur_munits_corps,al
pop ax
mov couleur_munits_coins,al
pop ax
mov couleur_munits_int2,al
pop ax
mov couleur_munits_int,al

mov dx,0
mov ss:[bp],dx


texte "+10 munitions",20,1,18


munitions_end :
popa
ret
verif_munitions endp

barre_du_haut proc

pusha
mov ax,0		; colonne d'arrivée
push ax
mov ax, 320 ;colonne de départ
push ax
mov ax, 0 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax


CALL trace_ligne


mov ax,0		; colonne d'arrivée
push ax
mov ax, 320 ;colonne de départ
push ax
mov ax, 16 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax


CALL trace_ligne







mov ax,0		; ligne d'arrivée
push ax
mov ax, 16 ;ligne de départ
push ax
mov ax, 265 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,0		; ligne d'arrivée
push ax
mov ax, 16 ;ligne de départ
push ax
mov ax, 43 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,0		; ligne d'arrivée
push ax
mov ax, 16 ;ligne de départ
push ax
mov ax, 90 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,0		; ligne d'arrivée
push ax
mov ax, 16 ;ligne de départ
push ax
mov ax, 140 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne



;*********Vies :
mov cx,7
mov dx,9
mov ah,0ch
Call haut

texte "x",4,1,2

CALL affiche_vies


;**********Munitions :
mov cx, 50
mov dx,11

CALL munits

texte "x",couleur_munits_corps,1,7


CALL affiche_munits


;**********Bombes

mov cx, 100
mov dx,10

CALL bombe

texte "x",couleur_bombes_int,1,14


CALL affiche_bombes

CALL affiche_points

popa
ret
barre_du_haut endp


barre_du_haut_editeur proc

pusha

CALL bordures

mov ax,0		; colonne d'arrivée
push ax
mov ax, 320 ;colonne de départ
push ax
mov ax, 0 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax


CALL trace_ligne


mov ax,0		; colonne d'arrivée
push ax
mov ax, 320 ;colonne de départ
push ax
mov ax, 16 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax


CALL trace_ligne





mov ax,0		; ligne d'arrivée
push ax
mov ax, 16 ;ligne de départ
push ax
mov ax, 43 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,0		; ligne d'arrivée
push ax
mov ax, 16 ;ligne de départ
push ax
mov ax, 90 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne


mov ax,0		; ligne d'arrivée
push ax
mov ax, 16 ;ligne de départ
push ax
mov ax, 140 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,0		; ligne d'arrivée
push ax
mov ax, 16 ;ligne de départ
push ax
mov ax, 300 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne


mov ax,0		; ligne d'arrivée
push ax
mov ax, 16 ;ligne de départ
push ax
mov ax, 280 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne


mov ax,5		; ligne d'arrivée
push ax
mov ax, 13 ;ligne de départ
push ax
mov ax, 312 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne


mov ax,5		; ligne d'arrivée
push ax
mov ax, 13 ;ligne de départ
push ax
mov ax, 306 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

;*********Vies :

texte "x",4,1,2

CALL affiche_vies


;**********Munitions :
mov cx, 50
mov dx,11

CALL munits

texte "x",couleur_munits_corps,1,7


CALL affiche_munits


;**********Bombes

mov cx, 100
mov dx,10

CALL bombe

texte "x",couleur_bombes_int,1,14


CALL affiche_bombes

mov al,9
mov cx,290
mov dx,9

CALL affichcoeur


popa
ret
barre_du_haut_editeur endp

;*******************************************************************LEVELS


lvl1 proc
	mov stock_bombes,0
	mov munitions_canon,20

	
CALL debut_niveau

mov nb_bombes,0
mov sp_bombes,sp

mov cx, 67
mov dx,57
CALL munits
push cx
push dx

mov cx, 97
mov dx,87
CALL munits
push cx
push dx

mov cx, 150
mov dx,30
CALL munits
push cx
push dx

mov cx, 150
mov dx,30
CALL munits
push cx
push dx

mov nb_munits,4
mov sp_munits,sp

CALL bordures




mov colonne_pers,160
mov ligne_pers,100


mov dir_pers,1
CALL personnage


mov nb_coeur,7			; nombre de coeurs
mov al,nb_coeur
mov nb_ennemis_restants,al


;-------------------------------------------------------- coordonnées septième coeur

mov bx,0 ;etat_streum (pas toucher)
push bx
mov ax, 1h			;vitesse
push ax
mov ax,1			; direction de départ
push ax

mov al,couleur_ennemis			;couleur de départ
push ax				
mov cx, 56	; colonne de départ
mov dx, 89			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées sixième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,1			; direction de départ
push ax

mov al,couleur_ennemis			;couleur de départ
push ax				
mov cx, 67		; colonne de départ
mov dx, 100			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées cinquième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,1			; direction de départ
push ax

mov al,couleur_ennemis 			;couleur de départ
push ax				
mov cx, 100			; colonne de départ
mov dx, 30		; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées quatrième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,4			; direction de départ
push ax

mov al,couleur_ennemis			;couleur de départ
push ax				
mov cx, 160		; colonne de départ
mov dx, 20		; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées troisième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,3			; direction de départ
push ax

mov al,couleur_ennemis			;couleur de départ
push ax				
mov cx, 100		; colonne de départ
mov dx, 165			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées deuxième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,2			; direction de départ
push ax

mov al,couleur_ennemis			;couleur de départ
push ax				
mov cx, 189		; colonne de départ
mov dx, 100			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,3			; direction de départ
push ax

mov al,couleur_ennemis			;couleur de départ
push ax				
mov cx, 100		; colonne de départ 
mov dx, 76			; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


	CALL barre_du_haut
	
CALL add_ons

	CALL coeur

ret
lvl1 endp

lvl2 proc
	
	
	mov stock_bombes,0
	mov munitions_canon,10

	
CALL debut_niveau

mov nb_bombes,0
mov sp_bombes,sp

mov cx, 67
mov dx,67
CALL munits
push cx
push dx

mov cx, 77
mov dx,87
CALL munits
push cx
push dx

mov nb_munits,2
mov sp_munits,sp

CALL bordures


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



mov ax,270		; colonne d'arrivée
push ax
mov ax, 50 ;colonne de départ
push ax
mov ax, 50 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,50	; colonne d'arrivée
push ax
mov ax, 270 ;colonne de départ
push ax
mov ax, 148 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne


mov ax,50	; colonne d'arrivée
push ax
mov ax, 148 ;colonne de départ
push ax
mov ax, 50 ;ligne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne


mov ax,50	; colonne d'arrivée
push ax
mov ax, 150 ;colonne de départ
push ax
mov ax, 270 ;ligne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov colonne_pers,56
mov ligne_pers,56


mov dir_pers,1
CALL personnage



mov nb_coeur,6			; nombre de coeurs
mov al,nb_coeur
mov nb_ennemis_restants,al




;-------------------------------------------------------- coordonnées sixième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,1			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 150		; colonne de départ
mov dx, 100			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées cinquième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,1			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 100			; colonne de départ
mov dx, 100			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées quatrième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,4			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 100		; colonne de départ
mov dx, 100			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées troisième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,3			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 100		; colonne de départ
mov dx, 100			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées deuxième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,2			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 100		; colonne de départ
mov dx, 100			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,3			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 135			; colonne de départ 
mov dx, 76			; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


	CALL barre_du_haut

CALL add_ons
	CALL coeur

	ret

lvl2 endp	


lvl3 proc
	
	
	mov stock_bombes,3
	mov munitions_canon,0

CALL debut_niveau

mov cx,167
mov dx,121
CALL bombe
push cx
push dx

mov cx,10
mov dx,87
CALL bombe
push cx
push dx

mov cx,147
mov dx,67
CALL bombe
push cx
push dx

mov cx,157
mov dx,180
CALL bombe
push cx
push dx

mov cx,310
mov dx,180
CALL bombe
push cx
push dx

mov nb_bombes,5
mov sp_bombes,sp


mov nb_munits,0
mov sp_munits,sp

CALL bordures


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



mov ax,50		; colonne d'arrivée
push ax
mov ax, 220 ;colonne de départ
push ax
mov ax, 60 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,20	; colonne d'arrivée
push ax
mov ax, 120 ;colonne de départ
push ax
mov ax, 148 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,140	; colonne d'arrivée
push ax
mov ax, 280 ;colonne de départ
push ax
mov ax, 148 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,115	; colonne d'arrivée
push ax
mov ax, 190 ;colonne de départ
push ax
mov ax, 90 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,70	; ligne d'arrivée
push ax
mov ax, 128 ;ligne de départ
push ax
mov ax, 80 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne


mov ax,160	; ligne d'arrivée
push ax
mov ax, 185 ;ligne de départ
push ax
mov ax, 40 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,75	; ligne d'arrivée
push ax
mov ax, 135 ;ligne de départ
push ax
mov ax, 270 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,30	; ligne d'arrivée
push ax
mov ax, 140 ;ligne de départ
push ax
mov ax, 240 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne




mov colonne_pers,10
mov ligne_pers,30


mov dir_pers,2
CALL personnage



mov nb_coeur,6			; nombre de coeurs
mov al,nb_coeur
mov nb_ennemis_restants,al




;-------------------------------------------------------- coordonnées sixième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,1			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 150		; colonne de départ
mov dx, 100			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées cinquième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,1			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 100			; colonne de départ
mov dx, 100			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées quatrième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,4			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 100		; colonne de départ
mov dx, 100			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées troisième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,3			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 100		; colonne de départ
mov dx, 100			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées deuxième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,2			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 100		; colonne de départ
mov dx, 100			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,3			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 135			; colonne de départ 
mov dx, 76			; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


	CALL barre_du_haut

CALL add_ons
	CALL coeur

	ret

lvl3 endp	


lvl4 proc
	
	
	mov stock_bombes,0
	mov munitions_canon,0


CALL debut_niveau

texte  "      ???   ",14,1,18



mov cx,20
mov dx,150
CALL bombe
push cx
push dx

mov cx,10
mov dx,150
CALL bombe
push cx
push dx


mov nb_bombes,2
mov sp_bombes,sp


mov nb_munits,0
mov sp_munits,sp


mov colonne_pers,10
mov ligne_pers,190


mov dir_pers,1
CALL personnage




CALL bordures


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



mov ax,18	; ligne d'arrivée
push ax
mov ax, 200 ;ligne de départ
push ax
mov ax, 50 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,18	; ligne d'arrivée
push ax
mov ax, 200 ;ligne de départ
push ax
mov ax, 100 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,18	; ligne d'arrivée
push ax
mov ax, 200 ;ligne de départ
push ax
mov ax, 150 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne




mov nb_coeur,1			; nombre de coeurs
mov al,nb_coeur
mov nb_ennemis_restants,al





;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,3			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 310		; colonne de départ 
mov dx, 20		; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


	CALL barre_du_haut

CALL add_ons
	CALL coeur

	ret

lvl4 endp	

lvl5 proc

CALL debut_niveau



construire_mur_vertical 0063,0096,0117,couleur_murs

construire_mur_vertical 0062,0095,0173,couleur_murs

construire_mur_horizontal 0089,0202,0138,couleur_murs

construire_mur_vertical 0137,0118,0203,couleur_murs

construire_mur_vertical 0117,0101,0206,couleur_murs

construire_mur_vertical 0136,0114,0087,couleur_murs

construire_mur_vertical 0113,0099,0085,couleur_murs

construire_mur_vertical 0103,0111,0137,couleur_murs

construire_mur_vertical 0104,0110,0148,couleur_murs

construire_mur_vertical 0102,0111,0148,couleur_murs

construire_mur_horizontal 0062,0052,0157,couleur_murs

construire_mur_vertical 0157,0166,0052,couleur_murs

construire_mur_vertical 0166,0171,0052,couleur_murs

construire_mur_horizontal 0052,0063,0171,couleur_murs

construire_mur_vertical 0171,0165,0063,couleur_murs

construire_mur_horizontal 0059,0066,0164,couleur_murs

construire_mur_vertical 0156,0170,0075,couleur_murs

construire_mur_vertical 0167,0172,0076,couleur_murs

construire_mur_horizontal 0076,0085,0155,couleur_murs

construire_mur_vertical 0155,0162,0085,couleur_murs

construire_mur_horizontal 0085,0076,0161,couleur_murs

construire_mur_vertical 0163,0166,0081,couleur_murs

construire_mur_horizontal 0081,0085,0166,couleur_murs

construire_mur_vertical 0166,0169,0085,couleur_murs

construire_mur_vertical 0167,0170,0085,couleur_murs

construire_mur_vertical 0171,0156,0094,couleur_murs

construire_mur_horizontal 0094,0106,0156,couleur_murs

construire_mur_vertical 0157,0171,0106,couleur_murs

construire_mur_horizontal 0106,0095,0171,couleur_murs

construire_mur_vertical 0171,0157,0116,couleur_murs

construire_mur_horizontal 0116,0126,0157,couleur_murs

construire_mur_vertical 0158,0170,0126,couleur_murs

construire_mur_horizontal 0117,0126,0162,couleur_murs

construire_mur_vertical 0156,0170,0133,couleur_murs

construire_mur_horizontal 0133,0141,0163,couleur_murs

construire_mur_vertical 0156,0168,0141,couleur_murs

construire_mur_vertical 0168,0171,0141,couleur_murs

construire_mur_vertical 0154,0168,0166,couleur_murs

construire_mur_vertical 0153,0168,0177,couleur_murs

construire_mur_vertical 0153,0167,0190,couleur_murs

mov colonne_pers,0142
mov ligne_pers,0101
mov dir_pers,0001
CALL personnage



placer_bombe 0098, 0141

placer_bombe 0124, 0141

placer_bombe 0145, 0141

placer_bombe 0169, 0141

placer_bombe 0192, 0142

mov nb_bombes,0005
mov sp_bombes,sp

placer_munits 0117, 0077

placer_munits 0173, 0077

placer_munits 0166, 0170

placer_munits 0177, 0169

placer_munits 0191, 0170

mov nb_munits,0005
mov sp_munits,sp

;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0004			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0156		; colonne de départ
mov dx,0050			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0004			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0163		; colonne de départ
mov dx,0042			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0004			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0173		; colonne de départ
mov dx,0037			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0130		; colonne de départ
mov dx,0052			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0119		; colonne de départ
mov dx,0044			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0110		; colonne de départ
mov dx,0036			; ligne de départ
push cx
push dx



mov stock_bombes,0000
mov munitions_canon,0000

CALL bordures

mov nb_coeur,0006		; nombre de coeurs
mov al,nb_coeur
mov nb_ennemis_restants,al

CALL barre_du_haut

CALL add_ons

CALL coeur

ret

lvl5 endp

lvl6 proc
	
	
	mov stock_bombes,1
	mov munitions_canon,0

CALL debut_niveau


mov nb_bombes,0
mov sp_bombes,sp


mov nb_munits,0
mov sp_munits,sp

mov colonne_pers,80
mov ligne_pers,80


mov dir_pers,2
CALL personnage

CALL bordures


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



mov ax,125		; colonne d'arrivée
push ax
mov ax,195  ;colonne de départ
push ax
mov ax, 90 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,125	; colonne d'arrivée
push ax
mov ax, 197 ;colonne de départ
push ax
mov ax, 120 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,90	; ligne d'arrivée
push ax
mov ax, 120 ;ligne de départ
push ax
mov ax, 195 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne


mov ax,90; ligne d'arrivée
push ax
mov ax, 120 ;ligne de départ
push ax
mov ax, 125;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne





mov nb_coeur,1		; nombre de coeurs
mov al,nb_coeur
mov nb_ennemis_restants,al





;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,4			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 160		; colonne de départ 
mov dx, 100		; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


	CALL barre_du_haut
CALL add_ons

	CALL coeur

	ret

lvl6 endp	


lvl7 proc
	
	
	mov stock_bombes,0
	mov munitions_canon,10

	
CALL debut_niveau

mov nb_bombes,0
mov sp_bombes,sp


mov nb_munits,0
mov sp_munits,sp

mov colonne_pers,160
mov ligne_pers,100


mov dir_pers,1
CALL personnage

CALL bordures


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



mov ax,125		; colonne d'arrivée
push ax
mov ax,195  ;colonne de départ
push ax
mov ax, 90 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,125	; colonne d'arrivée
push ax
mov ax, 197 ;colonne de départ
push ax
mov ax, 120 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,90	; ligne d'arrivée
push ax
mov ax, 120 ;ligne de départ
push ax
mov ax, 195 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne


mov ax,90; ligne d'arrivée
push ax
mov ax, 120 ;ligne de départ
push ax
mov ax, 125;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ah,0ch
mov al,0
mov cx,125
mov dx,105
int 10h
inc cx
int 10h

mov cx,195
mov dx,105
int 10h
inc cx
int 10h

mov cx,160
mov dx,120
int 10h
inc dx
int 10h

mov cx,160
mov dx,90
int 10h
inc dx
int 10h






mov nb_coeur,4	; nombre de coeurs
mov al,nb_coeur
mov nb_ennemis_restants,al





;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,3			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 20		; colonne de départ 
mov dx, 20		; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,3			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 300		; colonne de départ 
mov dx, 180	; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,3			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 20		; colonne de départ 
mov dx, 180	; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,3			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 300		; colonne de départ 
mov dx, 20	; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


	CALL barre_du_haut
CALL add_ons

	CALL coeur

	ret

lvl7 endp	



lvl8 proc
	
	
	
	mov stock_bombes,3
	mov munitions_canon,10

	
CALL debut_niveau

mov cx,10
mov dx,25
CALL bombe
push cx
push dx

mov cx,100
mov dx,27
CALL bombe
push cx
push dx

mov cx,150
mov dx,150
CALL bombe
push cx
push dx

mov cx,78
mov dx,190
CALL bombe
push cx
push dx

mov cx,190
mov dx,60
CALL bombe
push cx
push dx


mov nb_bombes,5
mov sp_bombes,sp

mov cx, 77
mov dx,87
CALL munits
push cx
push dx

mov cx, 177
mov dx,98
CALL munits
push cx
push dx

mov cx, 310
mov dx,45
CALL munits
push cx
push dx

mov cx, 270
mov dx,25
CALL munits
push cx
push dx

mov cx, 79
mov dx,150
CALL munits
push cx
push dx


mov nb_munits,5
mov sp_munits,sp

mov colonne_pers,160
mov ligne_pers,100


mov dir_pers,1
CALL personnage

CALL bordures






mov nb_coeur,10		; nombre de coeurs
mov al,nb_coeur
mov nb_ennemis_restants,al





;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,2			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 140		; colonne de départ 
mov dx, 20		; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,1			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 90		; colonne de départ 
mov dx, 90		; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,4			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 20	; colonne de départ 
mov dx, 150		; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,2			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 45		; colonne de départ 
mov dx, 100		; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,1			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 210		; colonne de départ 
mov dx, 180		; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,3			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 140		; colonne de départ 
mov dx, 96		; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,4			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 300		; colonne de départ 
mov dx, 100		; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,2			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 260		; colonne de départ 
mov dx,35		; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,1			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 110		; colonne de départ 
mov dx, 95		; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,3			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 195	; colonne de départ 
mov dx, 110		; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


	CALL barre_du_haut
CALL add_ons

	CALL coeur

	ret

lvl8 endp	



lvlhardcore proc
	mov stock_bombes,0
	mov munitions_canon,20


mov al,couleur_vaisseau
mov couleur_sav,al
mov couleur_vaisseau, 14
	
CALL debut_niveau

texte "hardcore lvl",5,1,18

mov nb_bombes,0
mov sp_bombes,sp

mov cx, 67
mov dx,57
CALL munits
push cx
push dx

mov cx, 97
mov dx,87
CALL munits
push cx
push dx

mov cx, 150
mov dx,30
CALL munits
push cx
push dx

mov cx, 150
mov dx,30
CALL munits
push cx
push dx

mov nb_munits,4
mov sp_munits,sp

CALL bordures




mov colonne_pers,160
mov ligne_pers,100


mov dir_pers,1
CALL personnage


mov nb_coeur,7			; nombre de coeurs
mov al,nb_coeur
mov nb_ennemis_restants,al


;-------------------------------------------------------- coordonnées septième coeur

mov bx,0 ;etat_streum (pas toucher)
push bx
mov ax, 1h			;vitesse
push ax
mov ax,1			; direction de départ
push ax

mov al,14  			;couleur de départ
push ax				
mov cx, 56	; colonne de départ
mov dx, 89			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées sixième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,1			; direction de départ
push ax

mov al,14			;couleur de départ
push ax				
mov cx, 67		; colonne de départ
mov dx, 100			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées cinquième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,1			; direction de départ
push ax

mov al,14 			;couleur de départ
push ax				
mov cx, 100			; colonne de départ
mov dx, 30		; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées quatrième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,4			; direction de départ
push ax

mov al,14			;couleur de départ
push ax				
mov cx, 160		; colonne de départ
mov dx, 20		; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées troisième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,3			; direction de départ
push ax

mov al,14			;couleur de départ
push ax				
mov cx, 100		; colonne de départ
mov dx, 165			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées deuxième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,2			; direction de départ
push ax

mov al,14			;couleur de départ
push ax				
mov cx, 189		; colonne de départ
mov dx, 100			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,3			; direction de départ
push ax

mov al,14			;couleur de départ
push ax				
mov cx, 100		; colonne de départ 
mov dx, 76			; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


	CALL barre_du_haut
	
CALL add_ons

	CALL coeur

ret
lvlhardcore endp

lvl10 proc
	
	
	mov stock_bombes,0
	mov munitions_canon,0

	
CALL debut_niveau

mov cx,10
mov dx,25
CALL bombe
push cx
push dx

mov cx,310
mov dx,25
CALL bombe
push cx
push dx

mov cx,310
mov dx,190
CALL bombe
push cx
push dx

mov cx,10
mov dx,190
CALL bombe
push cx
push dx

mov cx,160
mov dx,100
CALL bombe
push cx
push dx

mov nb_bombes,5
mov sp_bombes,sp


mov nb_munits,0
mov sp_munits,sp

mov colonne_pers,80
mov ligne_pers,80


mov dir_pers,1
CALL personnage

CALL bordures


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



mov ax,10		; colonne d'arrivée
push ax
mov ax, 62 ;colonne de départ
push ax
mov ax, 78 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,260	; colonne d'arrivée
push ax
mov ax, 308 ;colonne de départ
push ax
mov ax, 78 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,10	; colonne d'arrivée
push ax
mov ax, 60 ;colonne de départ
push ax
mov ax, 140 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,260	; colonne d'arrivée
push ax
mov ax, 308 ;colonne de départ
push ax
mov ax, 140 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,18	; ligne d'arrivée
push ax
mov ax, 78 ;ligne de départ
push ax
mov ax, 60 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne


mov ax,140	; ligne d'arrivée
push ax
mov ax, 200 ;ligne de départ
push ax
mov ax, 60 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,18	; ligne d'arrivée
push ax
mov ax, 78 ;ligne de départ
push ax
mov ax, 260 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,140	; ligne d'arrivée
push ax
mov ax, 200 ;ligne de départ
push ax
mov ax, 260 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,90	; colonne d'arrivée
push ax
mov ax, 232 ;colonne de départ
push ax
mov ax, 130 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,165	; colonne d'arrivée
push ax
mov ax, 230 ;colonne de départ
push ax
mov ax, 90 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,90	; colonne d'arrivée
push ax
mov ax, 155 ;colonne de départ
push ax
mov ax, 90 ;ligne concernée
push ax     
mov ax, 1  ;horizontale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,90	; ligne d'arrivée
push ax
mov ax, 130 ;ligne de départ
push ax
mov ax, 230 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne

mov ax,90	; ligne d'arrivée
push ax
mov ax, 130 ;ligne de départ
push ax
mov ax, 90 ;colonne concernée
push ax     
mov ax, 2  ;verticale
push ax
mov al, couleur_murs ;couleur ligne
push ax

CALL trace_ligne





mov nb_coeur,5			; nombre de coeurs
mov al,nb_coeur
mov nb_ennemis_restants,al






;-------------------------------------------------------- coordonnées cinquième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,1			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 20			; colonne de départ
mov dx, 25			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées quatrième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,4			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 20		; colonne de départ
mov dx, 180			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées troisième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,3			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 300		; colonne de départ
mov dx, 180			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées deuxième coeur

mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,4			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 300		; colonne de départ
mov dx, 25			; ligne de départ 		 (3 et 2 pour commencer en haut à gauche)
push cx
push dx

;-------------------------------------------------------- coordonnées premier coeur
mov bx,0 ;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,4			; direction de départ
push ax

mov al,couleur_ennemis  			;couleur de départ
push ax				
mov cx, 150		; colonne de départ 
mov dx, 110			; ligne de départ     	(3 et 2 pour commencer en haut à gauche)
push cx
push dx


	CALL barre_du_haut

CALL add_ons
	CALL coeur

	ret

lvl10 endp	

;; lvlX$

lvl11 proc

CALL debut_niveau



construire_mur_vertical 0041,0168,0038,couleur_murs

construire_mur_horizontal 0038,0281,0168,couleur_murs

construire_mur_vertical 0170,0042,0280,couleur_murs

;construire_mur_vertical 0169,0167,0280,couleur_murs

construire_mur_horizontal 0038,0282,0040,couleur_murs

construire_mur_vertical 0063,0144,0072,couleur_murs

construire_mur_horizontal 0072,0251,0144,couleur_murs

construire_mur_vertical 0146,0063,0251,couleur_murs

construire_mur_horizontal 0253,0072,0062,couleur_murs

construire_mur_vertical 0079,0130,0097,couleur_murs

construire_mur_horizontal 0097,0231,0130,couleur_murs

construire_mur_vertical 0132,0082,0230,couleur_murs

construire_mur_horizontal 0097,0232,0077,couleur_murs

;construire_mur_vertical 0077,0084,0231,couleur_murs

construire_mur_vertical 0079,0085,0230,couleur_murs

construire_mur_vertical 0115,0085,0124,couleur_murs

construire_mur_horizontal 0124,0194,0085,couleur_murs

construire_mur_vertical 0086,0115,0192,couleur_murs

construire_mur_horizontal 0124,0194,0114,couleur_murs

mov colonne_pers,0020
mov ligne_pers,0121
mov dir_pers,0001
CALL personnage



placer_bombe 0018, 0137

placer_bombe 0060, 0134

placer_bombe 0081, 0093

placer_bombe 0103, 0112

placer_bombe 00131, 0093

mov nb_bombes,0005
mov sp_bombes,sp

mov nb_munits,0000
mov sp_munits,sp

;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0004			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0055		; colonne de départ
mov dx,0111			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0002			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0078		; colonne de départ
mov dx,0112			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0001			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0116		; colonne de départ
mov dx,0097			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0002			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0156		; colonne de départ
mov dx,0101			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0004			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0021		; colonne de départ
mov dx,0054			; ligne de départ
push cx
push dx



mov stock_bombes,0001
mov munitions_canon,0000

CALL bordures

mov nb_coeur,0005		; nombre de coeurs
mov al,nb_coeur
mov nb_ennemis_restants,al

CALL barre_du_haut

CALL add_ons

CALL coeur

ret

lvl11 endp

lvl12 proc

CALL debut_niveau



construire_mur_vertical 0165,0146,0034,couleur_murs

construire_mur_horizontal 0034,0048,0146,couleur_murs

construire_mur_horizontal 0048,0060,0146,couleur_murs

construire_mur_vertical 0146,0164,0060,couleur_murs

construire_mur_horizontal 0060,0034,0164,couleur_murs

construire_mur_vertical 0145,0166,0090,couleur_murs

construire_mur_horizontal 0090,0118,0145,couleur_murs

construire_mur_vertical 0145,0165,0118,couleur_murs

construire_mur_horizontal 0118,0090,0165,couleur_murs

construire_mur_vertical 0145,0165,0151,couleur_murs

construire_mur_horizontal 0151,0179,0145,couleur_murs

construire_mur_vertical 0146,0165,0179,couleur_murs

construire_mur_horizontal 0178,0152,0165,couleur_murs

construire_mur_vertical 0144,0172,0223,couleur_murs

construire_mur_horizontal 0223,0249,0144,couleur_murs

construire_mur_vertical 0144,0164,0249,couleur_murs

construire_mur_horizontal 0249,0223,0164,couleur_murs

mov colonne_pers,0104
mov ligne_pers,0177
mov dir_pers,0001
CALL personnage



mov nb_bombes,0000
mov sp_bombes,sp

mov nb_munits,0000
mov sp_munits,sp

;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0047		; colonne de départ
mov dx,0056			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0065		; colonne de départ
mov dx,0056			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0083		; colonne de départ
mov dx,0056			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0106		; colonne de départ
mov dx,0056			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0124		; colonne de départ
mov dx,0056			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0141		; colonne de départ
mov dx,0056			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0159		; colonne de départ
mov dx,0056			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0174		; colonne de départ
mov dx,0056			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0190		; colonne de départ
mov dx,0056			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0206		; colonne de départ
mov dx,0057			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0222		; colonne de départ
mov dx,0057			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0233		; colonne de départ
mov dx,0054			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0233		; colonne de départ
mov dx,0054			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0248		; colonne de départ
mov dx,0060			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0047		; colonne de départ
mov dx,0075			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0062		; colonne de départ
mov dx,0074			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0083		; colonne de départ
mov dx,0074			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0105		; colonne de départ
mov dx,0075			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0127		; colonne de départ
mov dx,0075			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0141		; colonne de départ
mov dx,0074			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0157		; colonne de départ
mov dx,0075			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0173		; colonne de départ
mov dx,0074			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0191		; colonne de départ
mov dx,0074			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0207		; colonne de départ
mov dx,0072			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0222		; colonne de départ
mov dx,0075			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0235		; colonne de départ
mov dx,0075			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0250		; colonne de départ
mov dx,0075			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0250		; colonne de départ
mov dx,0087			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0234		; colonne de départ
mov dx,0087			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0218		; colonne de départ
mov dx,0087			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0204		; colonne de départ
mov dx,0086			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0190		; colonne de départ
mov dx,0086			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0171		; colonne de départ
mov dx,0085			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0155		; colonne de départ
mov dx,0087			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0141		; colonne de départ
mov dx,0087			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0126		; colonne de départ
mov dx,0087			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0106		; colonne de départ
mov dx,0087			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0082		; colonne de départ
mov dx,0087			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0062		; colonne de départ
mov dx,0087			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0044		; colonne de départ
mov dx,0087			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0044		; colonne de départ
mov dx,0103			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0060		; colonne de départ
mov dx,0101			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0079		; colonne de départ
mov dx,0101			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0105		; colonne de départ
mov dx,0101			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0125		; colonne de départ
mov dx,0105			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0146		; colonne de départ
mov dx,0105			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0160		; colonne de départ
mov dx,0105			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0170		; colonne de départ
mov dx,0104			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0189		; colonne de départ
mov dx,0105			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0202		; colonne de départ
mov dx,0102			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0216		; colonne de départ
mov dx,0102			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0234		; colonne de départ
mov dx,0103			; ligne de départ
push cx
push dx



;Monstre
mov bx,0;etat_streum
push bx
mov ax, 1h			;vitesse
push ax
mov ax,0003			; direction de départ
push ax
mov al,couleur_ennemis  			;couleur de départ
push ax
mov cx,0251		; colonne de départ
mov dx,0103			; ligne de départ
push cx
push dx



mov stock_bombes,0000
mov munitions_canon,0099

CALL bordures

mov nb_coeur,0053		; nombre de coeurs
mov al,nb_coeur
mov nb_ennemis_restants,al

CALL barre_du_haut

CALL add_ons

CALL coeur

ret

lvl12 endp

add_ons proc
	pusha
	cmp munit_infini,0
	JZ pas_de_cheat
	
	mov stock_bombes,99
	mov munitions_canon,999
	
	pas_de_cheat :
	popa
	ret

add_ons endp

debut_niveau proc

 
efface_ecran

mov ax,points
mov points_sav,ax

mov ax,nb_vies
mov nb_vies_sav,ax

mov ax,nb_coeurs_detruits
mov nb_coeurs_detruits_sav,ax

	mov mvt_pers,0
	mov nb_tirs, 0
	

ret	
debut_niveau endp


intro proc
	
		mov ax,13h
	int 10h
		mov ah,0bh
	mov bh, 0
	mov bl, 0
	int 10h
	
CALL ouverture_couleurs_vaisseau

texte "PixXxeL",4,2,16

texte "Projet assembleur",10,6,10

texte "par",10,8,10

texte <"MATTE C",82h,"lestin">,10,10,10

texte "IUT informatique de Metz",10,12,10

texte "2009 - 2010",10,14,10


mov nb_coeur,1		; nombre de coeurs


mov ah,0ch
mov cx,160 
mov dx,130

Call haut

clignotement_des_yeux :

mov al,9
mov cx,140
mov dx,130

CALL affichcoeur

mov al,9
mov cx,180
mov dx,130

CALL affichcoeur


mov att,1
CALL powse

mov al,0
mov ah, 6h ; lecture du buffer clavier
mov dl,0ffh
int 21h

cmp al,1BH
JE fin

cmp al,0
JNE fin_intro

JMP clignotement_des_yeux

fin_intro :
	
	ret

intro endp

menu proc

debut_menu :	
;			mov ax,13h
;	int 10h
;		mov ah,0bh
;	mov bh, 0
;	mov bl, 0
;	int 10h

efface_ecran


texte "MENU",4,2,16

texte <"Touches : ",18h,":i, ",19h,":k, espace pour choisir">,3,3,1

texte "PLAY",5,5,2

texte"Touches et explications",5,7,2

texte "Changer les couleurs du vaisseau",5,9,2

texte "Cheats",5,11,2

texte "Editeur de niveaux",5,13,2

texte "DOSBox mode (augmenter la vitesse)",5,15,2

	
	mov al,9
mov cx,10
mov ligne_curseur,42
mov dx,ligne_curseur

comps :	

mov dx,ligne_curseur

mov al,9
CALL affichcoeur
mov att,1
;CALL powse 

inc couleur_yeux

mov ah, 6h ; lecture du buffer clavier
mov dl,0ffh
int 21h
 
mov dx,ligne_curseur

cmp al,69H
JE monte_curseur
cmp al,6BH
JE descend_curseur
cmp al,20H
JE selection
cmp al,1BH
JE fin
JMP comps

monte_curseur :
cmp dx,42
JE comps
mov al,0
mov bl,couleur_yeux
mov couleur_yeux,0
CALL affichcoeur
mov al,9
sub ligne_curseur,16	; on déplace le curseur par unités de 16 pixels (2 lignes)
mov dx,ligne_curseur
mov couleur_yeux,bl
CALL affichcoeur

JMP comps

descend_curseur :
cmp dx,122
JE comps
mov al,0
mov bl,couleur_yeux
mov couleur_yeux,0
CALL affichcoeur
mov al,9
add ligne_curseur,16
mov dx,ligne_curseur
mov couleur_yeux,bl
CALL affichcoeur

	
JMP comps	
	
selection :

cmp dx,42
JE retour
cmp dx,58
JE touches
cmp dx,74
JE chg_coul_vaiss
cmp dx,90
JE cheats
cmp dx,106
JE editeur
cmp dx,122
JE menu_dosbox_mod


cheats :

CALL menu_cheats

JMP debut_menu

chg_coul_vaiss :

CALL vaiss_couleur

JMP debut_menu

touches :

CALL touche

JMP debut_menu

editeur :
CALL editeur_de_niveaux
JMP debut_menu

menu_dosbox_mod :
CALL menu_DOSBox_mode

JMP debut_menu
		
	retour :
	ret

menu endp


touche proc

efface_ecran


texte "TOUCHES",4,2,16



texte <"i/8 : ",18h>,7,5,2

texte <"k/5 : ",19h>,7,6,2


texte <"l/6 : ",1ah>,7,7,2

texte <"j/4 : ",1bh>,7,8,2

texte "espace : avancer/stopper le vaisseau",7,9,2

texte <"e : tir avec le canon du milieu (d",82h,"tru">,7,10,2

texte <"it les ennemis, munitions limit",82h,"es)">,7,11,5

texte "f : tir canon droit (fait seulement rebondir les ennemis)",7,12,2

texte "s : tir canon gauche (idem)",7,14,2

texte <"d : bombes (d",82h,"truit les murs)">,7,15,2

texte "p : pause",7,16,2

texte "r : recommencer le niveau (ne fait pas perdre de vie)",7,17,2

texte <82h,"chap : quitter">,7,19,2

texte "m : menu",7,20,2



texte "appuyez sur une touche pour continuer",8,22,1


mov ah,8
int 21h

cmp al,1BH
JE fin


ret
touche endp


vaiss_couleur proc
	
efface_ecran


texte "Espace pour retourner au menu",8,22,1

texte "J/L pour changer de couleur de coque",4,19,1
texte <"U/O pour changer de couleur int",82h,"rieure">,5,20,1
texte <"H/M pour changer de couleur ext",82h,"rieure">,6,21,1

texte "A : couleurs de base (moches)",2,2,3

mov ah,0ch
mov al,5
mov dx,142
mov cx,30
int 10h
mov cx, 286
int 10h
mov cx, 36
int 10h
dec cx
int 10h
mov cx,39
int 10h
inc cx
int 10h
inc dx
mov cx,30
int 10h
mov cx, 286
int 10h
mov cx, 36
int 10h
dec cx
int 10h
mov cx,39
int 10h
inc cx
int 10h
inc dx
mov cx,30
int 10h
mov cx, 286
int 10h
mov cx, 36
int 10h
dec cx
int 10h
mov cx,39
int 10h
inc cx
int 10h


mov tempw,5 ;épaisseur de la barre
mov dx, 140

boucle_grande_barre :

mov cx, 0ffh
mov al,0
mov ah, 0ch
mov di,30


boucle_barre_couleur :
push cx

mov cx,di
int 10h
inc al
inc di

pop cx
loop boucle_barre_couleur

dec dx

mov ax,tempw
dec ax
mov tempw,ax
cmp ax,0
JNZ boucle_grande_barre

	compschg :
	
mov dx, 142
mov cl,couleur_vaisseau
mov ch,0
add cx,30
mov ah,0ch
mov al, 14
int 10h

inc dx
mov cl,couleur_vaisseau_ext
mov ch,0
add cx,30
int 10h

inc dx
mov cl,couleur_vaisseau_int
mov ch,0
add cx,30
int 10h


	mov ah,0ch
	mov cx,160
	mov dx,100
	
	
	Call haut
	mov ah,8
	int 21h
	
	cmp al,6CH
	JE coul_up
	cmp al,6AH
	JE coul_down
	cmp al,	20H
	JE fin_chg_coul_vaiss
	cmp al,1BH
	JE fin_chg_coul_vaiss
	cmp al,'h'
	JE coul_ext_down
	cmp al,'m'
	JE coul_ext_up
	cmp al,'u'
	JE coul_int_down
	cmp al,'o'
	JE coul_int_up
	cmp al,'a'
	JE couleurs_de_base
	JMP compschg
	
	couleurs_de_base :
	mov couleur_vaisseau,8
	mov couleur_vaisseau_ext,0f7h
	mov couleur_vaisseau_int,10
		
	JMP compschg
	
	coul_up :
	
	mov dx, 142
mov cl,couleur_vaisseau
mov ch,0
add cx,30
mov ah,0ch
mov al,0
int 10h
	
	coul_up2 :
	
	inc couleur_vaisseau
	cmp couleur_vaisseau,0
	JE coul_up2
	cmp couleur_vaisseau,5
	JE coul_up2
	cmp couleur_vaisseau,9
	JE coul_up2
	cmp couleur_vaisseau,6
	JE coul_up2
	cmp couleur_vaisseau,10
	JE coul_up2
	
	JMP compschg
	
	coul_down :
	
		mov dx, 142
mov cl,couleur_vaisseau
mov ch,0
add cx,30
mov ah,0ch
mov al,0
int 10h

	coul_down2 :
	
	dec couleur_vaisseau
	cmp couleur_vaisseau,0
	JE coul_down2
	cmp couleur_vaisseau,5
	JE coul_down2
	cmp couleur_vaisseau,9
	JE coul_down2
	cmp couleur_vaisseau,6
	JE coul_down2
	cmp couleur_vaisseau,10
	JE coul_down2
	
	JMP compschg
	
	coul_ext_up :
	
		mov dx, 143
mov cl,couleur_vaisseau_ext
mov ch,0
add cx,30
mov ah,0ch
mov al,0
int 10h
	
	coul_ext_up2 :
		
	inc couleur_vaisseau_ext
	cmp couleur_vaisseau_ext,0
	JE coul_ext_up2
	cmp couleur_vaisseau_ext,5
	JE coul_ext_up2
	cmp couleur_vaisseau_ext,9
	JE coul_ext_up2
	cmp couleur_vaisseau_ext,6
	JE coul_ext_up2
	cmp couleur_vaisseau_ext,10
	JE coul_ext_up2
	
		JMP compschg
	
	coul_ext_down :
	
		mov dx, 143
mov cl,couleur_vaisseau_ext
mov ch,0
add cx,30
mov ah,0ch
mov al,0
int 10h
	
	coul_ext_down2 :

		dec couleur_vaisseau_ext
	cmp couleur_vaisseau_ext,0
	JE coul_ext_down2
	cmp couleur_vaisseau_ext,5
	JE coul_ext_down2
	cmp couleur_vaisseau_ext,9
	JE coul_ext_down2
	cmp couleur_vaisseau_ext,6
	JE coul_ext_down2
	cmp couleur_vaisseau_ext,10
	JE coul_ext_down2
	
		JMP compschg
	
	coul_int_up :
	
		mov dx, 144
mov cl,couleur_vaisseau_int
mov ch,0
add cx,30
mov ah,0ch
mov al,0
int 10h
	
	coul_int_up2 :
		
	inc couleur_vaisseau_int
	cmp couleur_vaisseau_int,0
	JE coul_int_up2
	cmp couleur_vaisseau_int,5
	JE coul_int_up2
	cmp couleur_vaisseau_int,9
	JE coul_int_up2
	cmp couleur_vaisseau_int,6
	JE coul_int_up2
	cmp couleur_vaisseau_int,10
	JE coul_int_up2
	
		JMP compschg
	
	coul_int_down :
	
		mov dx, 144
mov cl,couleur_vaisseau_int
mov ch,0
add cx,30
mov ah,0ch
mov al,0
int 10h
	
	coul_int_down2 :

		dec couleur_vaisseau_int
	cmp couleur_vaisseau_int,0
	JE coul_int_down2
	cmp couleur_vaisseau_int,5
	JE coul_int_down2
	cmp couleur_vaisseau_int,9
	JE coul_int_down2
	cmp couleur_vaisseau_int,6
	JE coul_int_down2
	cmp couleur_vaisseau_int,10
	JE coul_int_down2
	
		JMP compschg
		
	fin_chg_coul_vaiss :
	
	push ax

		MOV AH, 3CH
		LEA DX, temp_couleurs; création de fichier
		MOV CX,0
		INT 21H
		;JC AffERR
		mov num_logique_couleurs,ax
			
					MOV AH, 3DH
		MOV AL, 02h
		LEA DX, temp_couleurs
		INT 21H
		mov num_logique_couleurs,ax					;ouverture des fichiers
		;JC AffERR
	
lea dx,couleur_vaisseau
mov ah,40h
mov cx,1
mov bx,num_logique_couleurs
int 21h
mov ah,40h
mov cx,1
lea dx,couleur_vaisseau_int
int 21h
mov ah,40h
mov cx,1
lea dx,couleur_vaisseau_ext
int 21h


fermer_fichier num_logique_couleurs			
	
	pop ax
	cmp al,1BH
	JE FIN
	
	ret

vaiss_couleur endp

menu_cheats proc
	
		
efface_ecran
	
texte "CHEATS",4,2,16

cmp nl_allowed,0
JZ nl_OFF
texte "T pour niveau suivant : ON ",4,5,2
JMP nl_end
nl_OFF :
texte "T pour niveau suivant : OFF",4,5,2
nl_end :


cmp death_ON,0
JZ mi_ON
texte "Mode invincible : OFF",4,7,2
JMP mi_end
mi_ON : texte "Mode invincible : ON ",4,7,2
mi_end :


cmp vitesse_doublee,1
JE vitesse_x2
texte <"Vitesse X2 : OFF (attention : bugu",82h," !)">,4,9,2
JMP vitesse_end
vitesse_x2 : texte <"Vitesse X2 : ON  (attention : bugu",82h," !)">,4,9,2
vitesse_end :

cmp munit_infini,1 
JZ mun_ON
texte "Munitions infinies : OFF",4,11,2
JMP mun_end
mun_ON : texte "Munitions infinies : ON ",4,11,2
mun_end :

cmp vies_inf_on,1 
JZ vi_ON
texte "Vies infinies : OFF",4,13,2
JMP vi_end
vi_ON : texte "Vies infinies : ON ",4,13,2
vi_end :

cmp mode_speed_on,1
JZ sm_ON
texte "Speed max : OFF",4,15,2
JMP sm_end
sm_ON : texte "Speed max : ON ",4,15,2
sm_end :


texte "Retour",4,17,2

texte <"Lorsqu'un cheat au moins est activ",82h,",">,9,20,1
texte <"les points ne sont plus calcul",82h,"s">,9,21,2

texte <"Espace pour la s",82h,"lection">,8,22,1

	
		mov al,9
mov cx,10
mov ligne_curseur,42
mov dx,ligne_curseur

CALL affichcoeur

comps2 :	
 mov cx,10
mov dx,ligne_curseur

	mov ah,8
	int 21h

cmp al,69H
JE monte_curseur2
cmp al,6BH
JE descend_curseur2
cmp al,20H
JE selection2
cmp al,1BH
JE fin
JMP comps2


monte_curseur2 :
cmp dx,42
JE comps2
mov al,0
mov couleur_yeux,0
CALL affichcoeur
mov al,9
sub ligne_curseur,16
mov dx,ligne_curseur
CALL affichcoeur

JMP comps2

descend_curseur2 :
cmp dx,138				; changer ici pour ajouter un cheat (1/2)
JE comps2
mov al,0
mov couleur_yeux,0
CALL affichcoeur
mov al,9
add ligne_curseur,16
mov dx,ligne_curseur
CALL affichcoeur

	
JMP comps2	
	
selection2 :

cmp dx,42
JE next_lev
cmp dx,58
JE mode_inv
cmp dx,74
JE vit_x2		;On monte/descend de 16 pixels en 16 pixels
cmp dx,90
JE munits_inf
cmp dx,106
JE vies_inf
cmp dx,122
JE speed_max
cmp dx,138		; changer ici pour ajouter un cheat (2/2)
JE fin_cheats

JMP comps2

next_lev :
cmp nl_allowed,0
JZ next_level_ON
cmp nl_allowed,1
JE next_level_OFF

next_level_ON :

texte "T pour niveau suivant : ON ",4,5,2

mov nl_allowed,1
mov cheat_active,1
JMP comps2

next_level_OFF :

texte "T pour niveau suivant : OFF",4,5,2

mov nl_allowed,0
JMP comps2

mode_inv :
cmp death_ON,1
JE mode_inv_ON
JMP mode_inv_OFF

mode_inv_ON	:

texte "Mode invincible : ON ",4,7,2

	
mov death_ON,0	
mov cheat_active,1
JMP comps2
	
mode_inv_OFF :

texte "Mode invincible : OFF",4,7,2

mov death_ON,1
JMP comps2	

vit_x2 :
cmp vitesse_doublee,0
JE vitesse_x2_ON


vitesse_x2_OFF :

texte "Vitesse X2 : OFF",4,9,2

mov vitesse_doublee,0
JMP comps2

vitesse_x2_ON : 

texte "Vitesse X2 : ON ",4,9,2

mov vitesse_doublee,1
mov cheat_active,1
JMP comps2

munits_inf :
cmp munit_infini,0
JE muninf_ON


muninf_OFF :

texte "Munitions infinies : OFF",4,11,2

mov munit_infini,0
JMP comps2

muninf_ON : 

texte "Munitions infinies : ON ",4,11,2

mov munit_infini,1
mov cheat_active,1
JMP comps2


vies_inf :
cmp vies_inf_on,0
JZ viesinf_ON
cmp vies_inf_on,1
JE viesinf_OFF

viesinf_ON :

texte "Vies infinies : ON ",4,13,2

mov vies_inf_on,1
mov cheat_active,1
JMP comps2

viesinf_OFF :

texte "Vies infinies : OFF",4,13,2

mov vies_inf_on,0
JMP comps2


speed_max :

cmp mode_speed_on,0
JZ spm_ON
cmp mode_speed_on,1
JE spm_OFF

spm_ON :

texte "Speed max : ON ",4,15,2

mov mode_speed_on,1
mov cheat_active,1
JMP comps2

spm_OFF :

texte "Speed max : OFF",4,15,2

mov mode_speed_on,0
JMP comps2


	fin_cheats :
	
	cmp munit_infini,0
	JNZ fin_test_cheat_active 
	cmp vitesse_doublee,0
	JNZ fin_test_cheat_active
	cmp death_ON,1
	JNZ fin_test_cheat_active
	cmp nl_allowed,0
	JNZ fin_test_cheat_active
	cmp mode_speed_on,0
	JNE fin_test_cheat_active
	cmp vies_inf_on,0
	JNE fin_test_cheat_active
	
	mov cheat_active,0
	
	fin_test_cheat_active :
	
	ret

menu_cheats endp

conversion proc ; mettre le nombre à convertir dans tempw, et la longueur dans temp
	
pusha	



mov nb_converti,word ptr 0




mov bp,tempw ; backup de tempw (on affiche d'abord les 2 premiers digits)

mov ax,tempw
mov cl,100
DIV cl						; tempw <- tempw div 100
mov ah,0
mov tempw,ax	


mov ax,tempw
mov cl,10
DIV cl						; conv_digit <- tempw mod 10
mov al,ah
mov ah,0
mov conv_digit,ax

mov ax,tempw
mov cl,10
DIV cl							; tempw <- tempw div 10
mov ah,0
mov tempw,ax	


push di
mov di,[conv_digit]
add di,48 ; on convertit points_digit en code ASCII
mov cx,di
pop di



add nb_converti,cx




mov ax,tempw
mov cl,10
DIV cl						; points_digit <- points_prov mod 10
mov al,ah
mov ah,0
mov conv_digit,ax

mov ax,tempw
mov cl,10
DIV cl						; points_prov <- points_prov div 10
mov ah,0
mov tempw,ax	



push di
mov di,[conv_digit]
add di,48 ; on convertit points_digit en code ASCII
mov cx,di
pop di



mov ax,nb_converti
SHL ax,8 		; multiplication par 100h
mov nb_converti,ax


add nb_converti,cx



mov bx,num_logique
mov ah,40h
LEA dx, nb_converti ; affichage dans le fichier
mov cx,2
int 21h



mov tempw,bp ; on récupère tempw et on affiche les 2 derniers digits
;*****************
mov nb_converti,word ptr 0



mov ax,tempw
mov cl,10
DIV cl						; points_digit <- points_prov mod 10
mov al,ah
mov ah,0
mov conv_digit,ax

mov ax,tempw
mov cl,10
DIV cl						; points_prov <- points_prov div 10
mov ah,0
mov tempw,ax	


push di
mov di,[conv_digit]
add di,48 ; on convertit points_digit en code ASCII
mov cx,di
pop di



add nb_converti,cx



mov ax,tempw
mov cl,10
DIV cl						; points_digit <- points_prov mod 10
mov al,ah
mov ah,0
mov conv_digit,ax

mov ax,tempw
mov cl,10
DIV cl						; points_prov <- points_prov div 10
mov ah,0
mov tempw,ax	



push di
mov di,[conv_digit]
add di,48 ; on convertit points_digit en code ASCII
mov cx,di
pop di




mov ax,nb_converti
SHL ax,8 		; multiplication par 100h
mov nb_converti,ax


add nb_converti,cx


mov bx,num_logique
mov ah,40h
LEA dx, nb_converti
mov cx,2
int 21h

popa
	
	ret

conversion endp


comment /bip proc
pusha	
mov al,0
out 42h, al
mov al,0ah
out 42h,al
;
in al,61h
push ax
or al,3
out 61h,al
;
mov ax,150 ; durée du beep
xor cx,cx
Waiting :
	loop Waiting
	dec ax
	jnz Waiting
;
pop ax
out 61h,al	
popa
	ret

bip endp
/

menu_DOSBox_mode proc
	
	efface_ecran
	
	texte "DOSBox mode",4,2,16
	
	texte <"Ce mode ne marche que si vous utilisez l'",130,"mulateur DOSBox pour faire">,1,4,1
	texte "fonctionner ce jeu ; il ne marche pas",1,6,0
	texte "sous Windows XP.",1,7,0
	texte <"Il permet un jeu l",130,"g",138,"rement plus rapide que ne permet pas le mode normal">,1,8,1
	texte "(car la fonction 'pause' ne fonctionne pas sous Windows XP)",1,10,1
	
	
	cmp dosbox_mode_on,0
JZ dbm_OFF
texte "DOSBox mode : ON ",4,15,2
JMP dbm_end
dbm_OFF :
texte "DOSBox mode : OFF",4,15,2
dbm_end :
	
texte "Retour",4,17,2


	mov al,9
mov cx,10
mov ligne_curseur,122
mov dx,ligne_curseur

CALL affichcoeur

comps3 :	
 mov cx,10
mov dx,ligne_curseur

	mov ah,8
	int 21h

cmp al,69H
JE monte_curseur3
cmp al,6BH
JE descend_curseur3
cmp al,20H
JE selection3
cmp al,1BH
JE fin
JMP comps3


monte_curseur3 :
cmp dx,122
JE comps3
mov al,0
mov couleur_yeux,0
CALL affichcoeur
mov al,9
sub ligne_curseur,16
mov dx,ligne_curseur
CALL affichcoeur

JMP comps3

descend_curseur3 :
cmp dx,138				; changer ici pour ajouter un cheat (1/2)
JE comps3
mov al,0
mov couleur_yeux,0
CALL affichcoeur
mov al,9
add ligne_curseur,16
mov dx,ligne_curseur
CALL affichcoeur

	
JMP comps3	
	
selection3 :

cmp dx,122
JE chgdbm
cmp dx,138
JE fin_dbm

JMP comps3

chgdbm :

cmp dosbox_mode_on,0
JZ dbmo_ON
cmp dosbox_mode_on,1
JE dbmo_OFF

dbmo_ON :

texte "DOSBox mode : ON ",4,15,2

mov dosbox_mode_on,1
JMP comps3

dbmo_OFF :

texte "DOSBox mode : OFF",4,15,2

mov dosbox_mode_on,0

JMP comps3

fin_dbm :

	
	
	
	ret

menu_DOSBox_mode endp

Editeur_de_niveaux proc

; Note : la barre de l'éditeur de niveau peut contenir 17 caractères



		MOV AH, 3CH
		LEA DX, temp_editeur ; création de fichier
		MOV CX,0
		INT 21H
		JC AffERR
		mov num_logique_principal,ax

		MOV AH, 3CH
		LEA DX, temp_munits ; création de fichier
		MOV CX,0
		INT 21H
		JC AffERR
		mov num_logique_munits,ax
				
		MOV AH, 3CH
		LEA DX, temp_bombes ; création de fichier
		MOV CX,0
		INT 21H
		JC AffERR
		mov num_logique_bombes,ax
				
		MOV AH, 3CH
		LEA DX, temp_coeurs ; création de fichier
		MOV CX,0
		INT 21H
		JC AffERR	
		mov num_logique_coeurs,ax	
		
		JMP end_AffERR

AffERR :
	mov dl,al
		ADD dl,30h
		MOV AH,2
 		INT 21H	
 		LEA DX,Meserr
		MOV AH,09H
		INT 21H
			
	mov ah,1
	int 21h
			
			mov erreur,1
			
			JMP fin_editeur
			
		end_AffERR :
	

		
			MOV AH, 3DH
		MOV AL, 02h
		LEA DX, temp_editeur
		INT 21H
		mov num_logique_principal,ax
		JC AffERR


				MOV AH, 3DH
		MOV AL, 02h
		LEA DX, temp_munits
		INT 21H

		mov num_logique_munits,ax					;ouverture des fichiers
		JC AffERR
		
					MOV AH, 3DH 
		MOV AL, 02h
		LEA DX, temp_bombes
		INT 21H
		mov num_logique_bombes,ax
		JC AffERR
		
		;ouvrir_fichier temp_coeurs num_logique_coeurs

					MOV AH, 3DH 
		MOV AL, 02h
		LEA DX, temp_coeurs
		INT 21H
		mov num_logique_coeurs,ax
		JC AffERR	
	
mov bx,num_logique_principal
mov ah,40h
LEA dx, deb_niv
mov cx,l_deb_niv
int 21h
	
		mov ax,13h
	int 10h
		mov ah,0bh
	mov bh, 0
	mov bl, 0
	int 10h
	
mov stock_bombes,0
mov munitions_canon,0
mov nb_coeur,0
mov nb_bombes,0
mov nb_munits,0
efface_ecran

CALL barre_du_haut_editeur	

mov cx,7
mov dx,9
mov ah,0ch
Call haut

mov colonne_pers,7
mov ligne_pers,9
mov dir_pers,1

mov ax,0 ; initialisation souris
int 33h

comment /
mov ax, 9
lea dx,ad_curseur
mov bx,1
mov cx,1
int 33h


mov ax, 0ah
mov bx,0
mov cx,1
mov dx,1
int 33h
/

mov ax,1 ; affichage curseur
int 33h	

boucle_souris :

;mov ax,2 ; effacement curseur
;int 33h	

;mov ax,1 ; affichage curseur
;int 33h	

CALL barre_du_haut_editeur	



mov ax,3 ; acqusition état et position curseur
INT 33h

mov cx,0
mov dx,0

mov ax,5 ; lecture d'état d'enfoncement des boutons
mov bx,0 ; test bouton gauche
int 33h

cmp bx,0
JNZ differents_tests

mov ax,5 ; lecture d'état d'enfoncement des boutons
mov bx,1 ; test bouton droit
int 33h

cmp bx,0
JZ non_affichage_vaisseau

differents_tests : ; tests quant à l'endroit de l'écran ou l'on a cliqué

push dx
push ax
mov ax,cx
cwd
mov cx,2		;divise cx par 2
div cx
mov cx,ax
pop ax
pop dx

cmp cx,20
JA end_ch_etat_souris1
cmp dx,16
JA end_ch_etat_souris1
mov etat_souris,1
;cmp perso_place,0
;JZ un_suffit
;mov perso_place,1
texte "    placer       ",5,1,18
mov cx,230
mov dx,11
mov ah,0ch
Call haut
JMP boucle_souris
 end_ch_etat_souris1 :

cmp cx,110
JB end_bombes_up
cmp cx,140
JA end_bombes_up
cmp dx,16
JA end_bombes_up
cmp ax,1
JNE bombes_down
cmp stock_bombes,99
JE end_bombes_up
inc stock_bombes
JMP end_bombes_up
bombes_down :
cmp stock_bombes,0
JZ end_bombes_up
dec stock_bombes

end_bombes_up :

cmp cx,60
JB end_munits_up
cmp cx,90
JA end_munits_up
cmp dx,16
JA end_munits_up
cmp ax,1
JNE munits_down
cmp munitions_canon,999
JE end_munits_up
inc munitions_canon
JMP end_munits_up
munits_down :
cmp munitions_canon,0
JZ end_munits_up
dec munitions_canon

end_munits_up :

cmp cx,280
JB end_clic_monstre
cmp cx,300
JA end_clic_monstre
cmp dx,16
JA end_clic_monstre

mov etat_souris,2
texte "    placer       ",5,1,18
mov cx,230
mov dx,11
mov al,9
CALL affichcoeur

	JMP boucle_souris

end_clic_monstre :

cmp cx,303
JB end_clic_murs
cmp dx,16
JA end_clic_murs

mov etat_souris,3
texte "   placer murs    ",5,1,18
	
	JMP boucle_souris


end_clic_murs :

cmp cx,44
JB end_clic_munits
cmp cx,53
JA end_clic_munits
cmp dx,16
JA end_clic_munits

mov etat_souris,5
texte "    placer        ",5,1,18
mov cx,230
mov dx,11
CALL munits
	JMP boucle_souris
	
end_clic_munits :

cmp cx,92
JB end_clic_bombes
cmp cx,106
JA end_clic_bombes
cmp dx,16
JA end_clic_bombes

mov etat_souris,6
texte "    placer        ",5,1,18
mov cx,230
mov dx,11
CALL bombe
	JMP boucle_souris
	
end_clic_bombes :


cmp dx,16
JA end_test_plus_bas
cmp etat_souris,0
JNE plus_bas
end_test_plus_bas :


cmp etat_souris,1
JE placement_vaisseau

cmp etat_souris,2
JE placement_coeur

cmp etat_souris,3
JE placement_murs1

cmp etat_souris,4
JE placement_murs2

cmp etat_souris,5
JE placement_munits

cmp etat_souris,6
JE placement_bombes

JMP non_affichage_vaisseau

;mov ax,2 ; effacement curseur
;int 33h	

placement_vaisseau : ;place le vaisseau à l'écran et entre le code dans le fichier texte
	
	ecrire_dans num_logique_principal
	
mov colonne_pers,cx
mov ligne_pers,dx


mov etat_souris,0

pusha
efface_barre_editeur
mov ah,40h
LEA dx, placement_vaisseau1 ; bouts de texte
mov cx, l_placement_vaisseau1
mov bx,num_logique
int 21h
popa


push dx
mov tempw,cx
CALL conversion ;convertit cx en code ascii et l'affiche directement dans le fichier


mov bx,num_logique
mov ah,40h
LEA dx, placement_vaisseau2
mov cx, l_placement_vaisseau2
int 21h

pop dx
mov tempw,dx ; on convertit aussi dx
CALL conversion

mov bx,num_logique
mov ah,40h
LEA dx, placement_vaisseau3
mov cx, l_placement_vaisseau3
int 21h

saisie_direction :
;texte <"Dir ? (i",18h,"j",1Bh,"k",19h,"l",1ah,")">,14,1,18
;mov ah,8
;int 21h

	mov ax,2 ; effacement curseur
	int 33h	

mov ah,0ch
mov cx,colonne_pers
mov dx,ligne_pers
cmp dir_pers,1
JNE test_gauche
Call haut
JMP end_saisie_direction
test_gauche :
cmp dir_pers,4
JNE test_bas
gauche
JMP end_saisie_direction
test_bas :
cmp dir_pers,3

JNE test_droite
bas
JMP end_saisie_direction
test_droite :
droite
JMP end_saisie_direction

end_saisie_direction :


	mov ax,1 ; affichage curseur
	int 33h	

efface_barre_editeur

mov al,dir_pers
mov ah,0
mov tempw,ax
CALL conversion


mov bx,num_logique
mov ah,40h
LEA dx, placement_vaisseau4
mov cx, l_placement_vaisseau4
int 21h

JMP non_affichage_vaisseau ; fin de placement_vaisseau

placement_munits :
;$$


	ecrire_dans num_logique_munits

texte_fichier <saut_ligne,"placer_munits ">
convertir cx
texte_fichier " "
convertir dx


	mov ax,2 ; effacement curseur
	int 33h	
CALL munits
	mov ax,1 ; affichage curseur
	int 33h	


inc nb_munits



JMP non_affichage_vaisseau


placement_bombes :
;$$

	ecrire_dans num_logique_bombes


texte_fichier <saut_ligne,"placer_bombe ">
convertir cx
texte_fichier " "
convertir dx


	mov ax,2 ; effacement curseur
	int 33h	
CALL bombe
	mov ax,1 ; affichage curseur
	int 33h	


inc nb_bombes


	
JMP non_affichage_vaisseau

placement_coeur :

	

	ecrire_dans num_logique_coeurs

push dx
push cx

	mov ax,2 ; effacement curseur
	int 33h	
CALL affichcoeur
	mov ax,1 ; affichage curseur
	int 33h	


efface_barre_editeur
mov ah,40h
LEA dx, placement_coeur1 ; bouts de texte
mov cx, l_placement_coeur1
mov bx,num_logique
int 21h

texte <18h,1BH,"7 ",18h,1Ah,"9 ",19h,1Ah,"3 ",19h,1bh,"1 ?">,14,1,18

dir_pers_placement :
mov ah,8
int 21h
cmp al,37h
JE placement_dir_hg
cmp al,39h
JE placement_dir_hd
cmp al,33h
JE placement_dir_bd
cmp al,31h
JE placement_dir_bg

JMP dir_pers_placement

placement_dir_hg :
texte <18h,1BH>,1,1,30
mov tempw,1
JMP end_dir_pers_placement
placement_dir_hd :
texte <18h,1aH>,1,1,30
mov tempw,2
JMP end_dir_pers_placement
placement_dir_bd :
texte <19h,1aH>,1,1,30
mov tempw,3
JMP end_dir_pers_placement
placement_dir_bg :
texte <19h,1BH>,1,1,30
mov tempw,4
JMP end_dir_pers_placement

end_dir_pers_placement :

CALL conversion
texte "direction :",1,1,18
texte " OK",1,1,32

mov ah,40h
LEA dx, placement_coeur2 ; bouts de texte
mov cx, l_placement_coeur2
mov bx,num_logique
int 21h

pop cx
mov tempw,cx
CALL conversion

mov ah,40h
LEA dx, placement_coeur3 ; bouts de texte
mov cx, l_placement_coeur3
mov bx,num_logique
int 21h

pop dx
mov tempw,dx
CALL conversion

mov ah,40h
LEA dx, placement_coeur4 ; bouts de texte
mov cx, l_placement_coeur4
mov bx,num_logique
int 21h

inc nb_coeur
;mov etat_souris,0


non_affichage_vaisseau :

mov att,1
CALL powse


push dx	
mov al,0
mov ah, 6h ; lecture du buffer clavier
mov dl,0ffh
int 21h

pop dx

cmp al,1BH
JE fin_editeur_niveau
cmp al,6DH
JE fin_editeur_niveau
cmp al, 'j'
JE tourner_vaisseau_gauche
cmp al, 34h
JE tourner_vaisseau_gauche
cmp al, 'k'
JE tourner_vaisseau_bas
cmp al, 35h
JE tourner_vaisseau_bas
cmp al, 'l'
JE tourner_vaisseau_droite
cmp al, 36h
JE tourner_vaisseau_droite
cmp al, 'i'
JE tourner_vaisseau_haut
cmp al, 38h
JE tourner_vaisseau_haut


JMP boucle_souris
; ***************** nichts

plus_bas :
efface_barre_editeur
texte "     Plus bas    ",3,1,18
JMP non_affichage_vaisseau

;un_suffit :
;efface_barre_editeur
;texte <"Un ",87h,"a suffit !">,3,1,18
;JMP boucle_souris



tourner_vaisseau_gauche :
texte "  ",1,1,0
texte "  ",1,0,0
mov cx,7
mov dx,9
mov ah,0ch
gauche
mov dir_pers,4
JMP boucle_souris

tourner_vaisseau_haut :
texte "  ",1,1,0
texte "  ",1,0,0
mov cx,7
mov dx,9
mov ah,0ch
Call haut
mov dir_pers,1
JMP boucle_souris

tourner_vaisseau_droite :
texte "  ",1,1,0
texte "  ",1,0,0
mov cx,7
mov dx,9
mov ah,0ch
droite
mov dir_pers,2
JMP boucle_souris

tourner_vaisseau_bas :
texte "  ",1,1,0
texte "  ",1,0,0
mov cx,7
mov dx,9
mov ah,0ch
bas
mov dir_pers,3
JMP boucle_souris

placement_murs1 :




	mov ax,2 ; effacement curseur
	int 33h	
mov ah,0ch
int 10h
;inc cx
;int 10h
;inc dx
;int 10h
;dec cx
;int 10h
;dec dx
	mov ax,1 ; affichage curseur
	int 33h	
mov ah,0ch
int 10h
;inc cx
;int 10h
;inc dx
;int 10h
;dec cx
;int 10h
;dec dx

push cx
push dx

mov etat_souris,4


JMP boucle_souris

placement_murs2 :

	ecrire_dans num_logique_principal

pop bx ;dx
pop ax ;cx

pusha

cmp cx,ax
JG non_echange1
XCHG ax,cx
non_echange1 :

cmp dx,bx
JG non_echange2
XCHG dx,bx
non_echange2 :

sub cx,ax
sub dx,bx

cmp cx,dx 			; on compare la différence des coordonnées lignes et des coordonnées colonnes
JNG mur_vertical	; pour savoir si la ligne tracée est horizontale ou verticale

;*******mur horizontal :

popa
	push ax
	mov ax,2 ; effacement curseur
	int 33h
	pop ax	
construire_mur_horizontal ax,cx,bx,couleur_murs
	push ax
	mov ax,1 ; affichage curseur
	int 33h	
	pop ax



texte_fichier <saut_ligne,"construire_mur_horizontal ">


convertir ax
texte_fichier ","
convertir cx
texte_fichier ","
convertir bx
texte_fichier ",couleur_murs"

mov etat_souris,3
JMP boucle_souris

mur_vertical :

popa

mov cx,ax

	mov ax,2 ; effacement curseur
	int 33h	
construire_mur_vertical bx,dx,cx,couleur_murs
	mov ax,1 ; affichage curseur
	int 33h	



texte_fichier <saut_ligne,"construire_mur_vertical ">
convertir bx
texte_fichier ","
convertir dx
texte_fichier ","
convertir cx
texte_fichier ",couleur_murs"

mov etat_souris,3
JMP boucle_souris


fin_editeur_niveau :
mov ah,0
push ax

mov ax_pushe,1

mov ax,2 ; effacement curseur
int 33h	


; ******** fin fichier munitions
	ecrire_dans num_logique_munits

texte_fichier <saut_ligne,"mov nb_munits,">
mov cx,nb_munits
convertir cx
texte_fichier <0dh,"mov sp_munits,sp">


; ******** fin fichier bombes
	ecrire_dans num_logique_bombes

texte_fichier <saut_ligne,"mov nb_bombes,">
mov cx,nb_bombes
convertir cx
texte_fichier <0dh,"mov sp_bombes,sp">

;********* fin fichier principal
	
	ecrire_dans num_logique_principal
	

;texte_fichier <saut_ligne,";Fin de l'editeur de niveaux :",saut_ligne>

;;;;

copier_fichier temp_bombes, num_logique_bombes, num_logique
copier_fichier temp_munits, num_logique_munits, num_logique
copier_fichier temp_coeurs, num_logique_coeurs, num_logique

texte_fichier <saut_ligne,"mov stock_bombes,">

mov ax,stock_bombes
mov tempw,ax
CALL conversion

texte_fichier <0dh,"mov munitions_canon,">

mov ax,munitions_canon
mov tempw,ax
CALL conversion

texte_fichier <saut_ligne,"CALL bordures">


texte_fichier <saut_ligne,"mov nb_coeur,">

mov al,nb_coeur
mov ah,0
mov tempw,ax
CALL conversion

texte_fichier <"		; nombre de coeurs",0dh,"mov al,nb_coeur",0dh,"mov nb_ennemis_restants,al">





texte_fichier <saut_ligne,"CALL barre_du_haut",saut_ligne, "CALL add_ons", saut_ligne, "CALL coeur",saut_ligne,"ret",saut_ligne,"lvlX endp">

; effacement des fichiers :

mov ah,41h
lea dx, temp_coeurs
int 21h
JC AffERR

mov ah,41h
lea dx, temp_munits
int 21h
JC AffERR

mov ah,41h
lea dx, temp_bombes
int 21h
JC AffERR


fermer_fichier num_logique_principal
fermer_fichier num_logique_munits
fermer_fichier num_logique_bombes
fermer_fichier num_logique_coeurs


pop ax
cmp al,1BH
JE fin

;ùù
fin_editeur :
cmp ax_pushe,0
JZ ax_pas_pushe 	; pour éviter les bugs après l'affichage d'une erreur
cmp erreur,0
JZ ax_pas_pushe
pop bx
mov ax_pushe,0
mov erreur,0

ax_pas_pushe :

	ret

Editeur_de_niveaux endp

haut proc

mov	al,couleur_vaisseau_int
int 10h
dec dx
int 10h
dec dx;
int 10h;
mov al,couleur_vaisseau
dec dx
int 10h
dec cx
inc dx
int 10h
inc dx
int 10h
inc dx;
int 10h;
add cx,2
int 10h
dec dx
int 10h
dec dx;
int 10h;
add dx,3;
inc cx
int 10h
dec cx
int 10h
dec cx
int 10h
dec cx
int 10h
dec cx
int 10h
dec cx
inc dx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
inc dx
sub cx,2
int 10h
sub cx,2
int 10h

mov al,couleur_vaisseau_ext
sub cx,2
sub dx,2
int 10h
dec dx
int 10h
add cx,6
int 10h
inc dx
int 10h

ret
haut endp

bombe proc

	
mov al,couleur_bombes_int
	sub cx, 3

	mov ah, 0ch
	int 10h

	inc cx
	inc dx
	int 10h

	inc cx
	inc dx
	int 10h

	inc cx
	inc dx
	int 10h

	inc cx
	
	
	dec dx
	int 10h
	
	inc cx
	dec dx
	int 10h

	inc cx
	dec dx
	int 10h

	dec dx
	int 10h		

	dec cx
	dec dx
	int 10h		

	dec cx
	int 10h		

	dec cx
	inc dx
	int 10h		

	dec cx
	dec dx
	int 10h

	dec cx
	int 10h

	dec cx
	inc dx
	int 10h	
	
	mov al,couleur_bombes_ext
	dec cx
	sub dx,2
	int 10h
	inc cx
	int 10h
	inc cx
	int 10h
	inc cx
	int 10h
	inc cx
	int 10h
	inc cx
	int 10h
	inc cx
	int 10h
	inc cx
	int 10h
	inc cx
	int 10h

	inc dx
	int 10h
	inc dx
	int 10h
	inc dx
	int 10h
	inc dx
	int 10h
	inc dx
	int 10h
	inc dx
	int 10h
	inc dx
	int 10h
	
	dec cx
	int 10h
	dec cx
	int 10h
	dec cx
	int 10h
	dec cx
	int 10h
	dec cx
	int 10h
	dec cx
	int 10h
	dec cx
	int 10h
	dec cx
	int 10h
	
	dec dx
	int 10h
	dec dx
	int 10h
	dec dx
	int 10h
	dec dx
	int 10h
	dec dx
	int 10h
	dec dx
	int 10h
	
	add cx,4
	add dx,2
	

ret
	
bombe endp


munits proc
;placer les coordonnées dans cx et dx

mov ah,0ch
mov al,couleur_munits_int
int 10h
mov al,couleur_munits_int2
inc cx
int 10h
dec cx
inc dx
int 10h
dec cx
dec dx
int 10h
inc cx
dec dx
int 10h
mov al,couleur_munits_corps
dec dx
int 10h
inc cx
int 10h
inc dx
int 10h
inc cx
int 10h
inc dx
int 10h
inc dx
int 10h
dec cx
int 10h
inc dx
int 10h
dec cx
int 10h
dec cx
int 10h
dec dx
int 10h
dec cx
int 10h
dec dx
int 10h
dec dx
int 10h
inc cx
int 10h
dec dx
int 10h
mov al,couleur_munits_coins
dec cx
int 10h
add dx,4
int 10h
add cx,4
int 10h
sub dx,4
int 10h

add dx,2
sub cx,2
	ret
munits endp

ouverture_couleurs_vaisseau proc
	
					MOV AH, 3DH
		MOV AL, 02h
		LEA DX, temp_couleurs
		INT 21H
		mov num_logique_couleurs,ax					;ouverture des fichiers
		JC no_exists
		
		mov ah,3Fh
		lea dx,couleur_vaisseau
		mov cx,1
		mov bx,num_logique_couleurs
		int 21h
		
		mov ah,3Fh
		lea dx,couleur_vaisseau_int
		int 21h
		
		mov ah,3Fh
		lea dx,couleur_vaisseau_ext
		int 21h			
		
		fermer_fichier num_logique_couleurs
		
		no_exists :	
		
	ret

ouverture_couleurs_vaisseau endp

;************************************************************************
;************************************************************************
;************************************************************************
;;  variables

couleur_fond db 0
vitesse dw ?
att dw 0001h  ;OOO1h=> 55ms
direction dw ?
nb_coeur db ?
osef dw ?
nb_coeur_prov dw ?
ad_pile dw ?
nb_parametres_coeur db 12
colonne_pers dw ?
ligne_pers dw ?
dir_pers db ?
couleur_vaisseau db 8
couleur_vaisseau_int db 10
couleur_vaisseau_ext db 0f7h
couleur_sav db ?
;couleur_ennemis db 5 ;;;5
temp db ?
tempw dw ?
etat_reacteurs db 0 ;jaune : couleur 14
mvt_pers db 0
sav1 dw ?
sav2 dw ?
sav3 dw ?
sav4 dw ?
nb_tirs dw 0 ;see for bug
nb_tir_prov dw ?
nb_parametres_tir dw 8
;couleur_murs db 9
savsp dw ?
premier_tir db 1
sp_depassee db 0
couleur_yeux db 1
etat_streum db 0

;********* variables cheats :
Death_ON db 1 ; à mettre à 0 pour désactiver les morts
munit_infini db 0 ; à mettre à 1 pour munitions infinies
vies_inf_on db 0
mode_speed_on db 0
dosbox_mode_on db 0
;******************

nb_vies dw 4 ; nombres de vies
cheat_active dw 0
msg_nb_vies_end :
msg_nb_vies dw ?
nb_vies_prov dw 0
nb_vies_digit dw 0
longueur_vie db ?

msg_nb_mun_end :
msg_nb_mun dw ?
nb_mun_prov dw 0
nb_mun_digit dw 0
longueur_mun db ?

msg_nb_bombes_end :
msg_nb_bombes dw ?
nb_bombes_prov dw 0
nb_bombes_digit dw 0
longueur_nb_bombes db ?

points dw 0

points_prov dw 0
points_digit dw 0
points_sav dw ?	
nb_vies_sav dw ?
longueur_points db ?
msg_points dw ?	
couleur_msg_destroy_coeur db 1
munitions_canon dw 10 ; munitions
couleur_munits_int db 14
couleur_munits_int2 db 4
couleur_munits_corps db 10
couleur_munits_coins db 0F0h
couleur_bombes_int db 14
couleur_bombes_ext db 1
nb_bombes dw 0
nb_munits dw 0
sp_bombes dw ?
sp_munits dw ?
stock_bombes dw 0 ; bombes
etat_msg_destroy_coeur db 0
bool_bombe db 0
level db 1
nb_ennemis_restants db ?
nb_coeurs_detruits dw 0
nb_coeurs_detruits_sav dw 0
ligne_curseur dw 0
nl_allowed db 0

vitesse_doublee db 0
		
;bip db 7

sav_cx dw ?
sav_dx dw ?
		
;*** éditeur de niveaux :
;perso_place db 0
longueur_conv dw ?
conv_digit dw ?
nb_converti dw 4 dup (0h)

etat_souris db 0
temp_editeur DB "temp_editeur.TXT",0
temp_munits db "temp_munits.TXT",0
temp_bombes db	"temp_bombes.TXT",0
temp_coeurs db "temp_coeurs.TXT",0
Meserr db "erreur d'acces au fichier",24h

placement_vaisseau1 db saut_ligne,"mov colonne_pers,"
l_placement_vaisseau1 EQU 	$-placement_vaisseau1
placement_vaisseau2 db 0dh,"mov ligne_pers,"
l_placement_vaisseau2 EQU 	$-placement_vaisseau2
placement_vaisseau3 db 0dh,"mov dir_pers,"
l_placement_vaisseau3 EQU 	$-placement_vaisseau3
placement_vaisseau4 db 0dh,"CALL personnage",0dh,0dh
l_placement_vaisseau4 EQU 	$-placement_vaisseau4
num_logique dw ?
num_logique_principal dw ?
num_logique_munits dw ?
num_logique_bombes dw ?
num_logique_coeurs dw ?
deb_niv db "lvlX proc",saut_ligne,"CALL debut_niveau",saut_ligne
l_deb_niv equ $-deb_niv

placement_coeur1 db saut_ligne,";Monstre",0dh,"mov bx,0;etat_streum",0dh,"push bx",0dh,"mov ax, 1h			;vitesse",0dh,"push ax",0dh,"mov ax,"
l_placement_coeur1 equ $-placement_coeur1
placement_coeur2 db "			; direction de départ",0dh,"push ax",0dh,"mov al,couleur_ennemis  			;couleur de départ",0dh,"push ax",0dh,"mov cx,"
l_placement_coeur2 equ $-placement_coeur2
placement_coeur3 db "		; colonne de départ",0dh,"mov dx,"
l_placement_coeur3 equ $-placement_coeur3
placement_coeur4 db "			; ligne de départ",0Dh,"push cx",0dh,"push dx",saut_ligne
l_placement_coeur4 equ $-placement_coeur4

ax_pushe db 0
erreur db 0

testtt dw ?
l_testtt equ $-testtt
testt db "test"
l_testt equ $-testt

temp_copie db 80 dup ("W")

;***
num_logique_couleurs dw ?
temp_couleurs DB "couleurs_vaisseau.TXT",0
;ad_curseur db "TEST"
sav_test dw ?

	CSEG	ENDS	
		END MAIN
