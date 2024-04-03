.ifndef CONVODATA_S
CONVODATA_S = 1

; Potrait filenames
mainguy_filename: .asciiz "mgy.bin"
maingirl_filename: .asciiz "mgl.bin"
corpguy_filename: .asciiz "cgy.bin"
corpgirl_filename: .asciiz "cgl.bin"
evilguy_filename: .asciiz "egy.bin"
evilgirl_filename: .asciiz "egl.bin"
sideguy_filename: .asciiz "sgy.bin"
sidegrl_filename: .asciiz "sgl.bin"
daughter_filename: .asciiz "dau.bin"

potrait_filename_table: .word mainguy_filename, maingirl_filename, corpguy_filename, corpgirl_filename, evilguy_filename, evilgirl_filename, sideguy_filename, sidegrl_filename, daughter_filename

.define GUY_FIRST "JOHN"
.define GUY_LAST "SMITH"

; 34 max chars per convo row

convo_1:
    .byte 8, 0
    .byte 0, 0
    .asciiz "THANK YOU FOR WHAT YOU ARE DOING. I KNOW YOU ARE TAKING A HUGE RISK GETTING US THESE SUPPLIES. I CAN'T ASK YOU TO DO THIS AGAIN."
    .byte 1, 0
    .asciiz "DON'T WORRY ABOUT ME. JUST LET ME KNOW WHAT ELSE YOU NEED."
    .byte 0, 0
    .asciiz "WELL, FOOD AND MEDICAL SUPPLIES AS ALWAYS, BUT I ALSO WORRY ABOUT THE KIDS DOWN HERE. MOST OF THEM DON'T EVEN HAVE A SINGLE TOY."
    .byte 1, 1
    .asciiz "SAY NO MORE. SANTA IS ON HIS WAY. SPEAKING OF KIDS, HOW IS YOUR SON FEELING?"
    .byte 0, 1
    .asciiz "THE MEDS YOU BROUGHT SEEM TO BE WORKING. I JUST WISH WE HAD BETTER DOCTORS HERE. I'M NOT SURE THIS COLONY WILL MAKE IT."
    .byte 1, 0
    .asciiz "HANG IN THERE, MORE SUPPLIES ARE #%$*&!@.01....(BUZZ). DAMN, ITS THE CORPORATION!"
    .byte 254
    .byte 0, 2
    .asciiz "GET OUT OF THERE!"
    .byte 1, 0
    .asciiz "I WILL...(STATIC)...SUPPLIES...(STATIC)...(SIGNAL DEAD)..."
    .byte 0, 2
    .asciiz "HELLO? HELLO? ARE YOU STILL THERE!"
    .byte 253 ; new convo
    .byte 2, 0 ; What 2 portraits to load
    .byte 0, 0 ; Potrait to show and frame
    .asciiz "HELLO MR. ", GUY_LAST, ". I'M GLAD YOU HAVE CHOSEN TO JOIN US." ; Text for that portrait
    .byte 1, 0 ; Next potrait to show
    .asciiz "DIDN'T SEEM LIKE MUCH OF A CHOICE." ; Text for that portrait
    .byte 0, 0
    .asciiz "WE ALL MAKE CHOICES MR. ", GUY_LAST, ". YOU CHOSE TO STEAL FROM THE|CORPORATION. BUT, I'D GUESS YOU DIDN'T CHOOSE TO GET CAUGHT."
    .byte 1, 1
    .asciiz "DECISION MAKING WAS NEVER MY STRONG SUIT."
    .byte 0, 0
    .asciiz "WELL, LET'S HOPE THAT TURNS|AROUND. SEE, THE JUDGE HAS CHOOSEN TO ASSIGN YOU TO WORK FOR ME UNTIL YOUR DEBT IS PAID."
    .byte 1, 2
    .asciiz "DID HE CHOSE THAT BEFORE OR AFTER YOU PAID FOR HIS LAST VACATION?"
    .byte 254
    .byte 0, 2
    .asciiz "NO NEED FOR ACCUSATIONS MR. ", GUY_LAST, ". WOULD YOU RATHER THE ALTERNATIVE AND SERVE 20 YEARS OF HARD LABOR?"
    .byte 1, 1
    .asciiz "WELL, I HEAR THE PENAL COLONIES ARE NICE THIS TIME OF YEAR."
    .byte 0, 0
    .asciiz "HMM, THE LAST PILOT WHO TURNED US DOWN DIDN'T LAST A WEEK AT THE COLONIES. I HEAR IT CAN BE QUITE BRUTAL."
    .byte 1, 1
    .asciiz "PERHAPS MY SUNNY DISPOSITION WOULD MAKE ME POPULAR THERE?"
    .byte 0, 2
    .asciiz "LET'S CUT TO THE CHASE MR. ", GUY_LAST, ". YOU BELONG TO ME NOW. DO WELL AND YOU MAY PAY OFF YOUR DEBT."
    .byte 1, 1
    .asciiz "AND IF I DON'T DO WELL IS THERE SOME KIND OF PAYMENT PLAN?"
    .byte 254
    .byte 0, 2
    .asciiz "I SUGGEST YOU START TAKING THIS SERIOUSLY MR. ", GUY_LAST, ". MY PLANS FOR YOU ARE VERY LUCRATIVE...BUT QUITE DANGEROUS."
    .byte 1, 1
    .asciiz "SO, A 50-50 SPLIT OF THE PROFITS THEN?"
    .byte 0, 0
    .asciiz "OH MR. ", GUY_LAST, ", YOUR FIRST CONCERN SHOULD BE STAYING ALIVE. DEEP SCAVENGING IS A RISKY BUSINESS."
    .byte 0, 2
    .asciiz "EVEN FOR A LEGENDARY PILOT SUCH AS YOURSELF, YOUR SKILLS WILL BE PUSHED TO THEIR LIMITS. PERHAPS YOU ARE NOT CUT OUT FOR THIS?"
    .byte 1, 2
    .asciiz "SAVE YOUR MOTIVATIONAL SPEECH. I'M IN. JUST TELL ME HOW THIS WORKS EXACTLY?"
    .byte 0, 0
    .asciiz "GOOD...GOOD...(LAUGHS)"
    .byte 254
    .byte 0, 2
    .asciiz "USING OUR WARP GATE TECHNOLOGY, WE WILL TRANSPORT YOU AND YOUR SHIP INTO THE MIDDLE OF DEEP SPACE ASTEROID FIELDS."
    .byte 1, 0
    .asciiz "I HATE THIS PLAN ALREADY."
    .byte 0, 2
    .asciiz "THE ASTEROIDS CONTAIN SOME OF THE GALAXY'S MOST VALUABLE|CRYSTALS AND MINERALS. YOU WILL HARVEST THEM."
    .byte 0, 2
    .asciiz "USE YOUR MISSILES TO BLAST THE ASTEROIDS OPEN AND GRAB THE GOODS. AVOID CRASHING AND BEWARE OF OTHER, UM 'HAZARDS'."
    .byte 1, 2
    .asciiz "THANKS FOR THE PRO TIP. NOW, YOU CASUALLY MENTIONED 'HAZARDS'? WOULD YOU BE KIND ENOUGH TO|ELABORATE?"
    .byte 0, 2
    .asciiz "WELL, SOME OF THE CRYSTALS ARE EXPLOSIVE. I'D SKIP THOSE. AND YOU MAY NOT BE ALONE OUT THERE."
    .byte 254
    .byte 1, 0
    .asciiz "OK, THAT IS DEEPLY TROUBLING. FOR FUN, LET'S ASSUME I CAN GRAB SOME LOOT AND STAY ALIVE. WHAT THEN?"
    .byte 0, 2
    .asciiz "ONCE THE WARP GATE SENSES THAT THE AREA IS MOSTLY DEPLETED, IT WILL OPEN FOR YOU TO FLY BACK IN."
    .byte 0, 2
    .asciiz "BE CAREFUL AROUND THE WARP GATE. CRASHING INTO IT WILL DESTROY YOUR SHIP. SPEAKING OF DEATH, I DO HAVE SOME GOOD NEWS."
    .byte 0, 2
    .asciiz "USING SHORT-RANGED INSTANT WARP TECHNOLOGY, THE GATE WILL BE ABLE TO SAVE YOU FROM DEATH A FEW TIMES."
    .byte 1, 0
    .asciiz "VERY REASSURING."
    .byte 0, 2
    .asciiz "WELL THAT'S IT. IF THERE ARE NO QUESTIONS, I SAY WE GET STARTED...3...2...1..."
    .byte 255

convo_2:
    .byte 0, 1
    .byte 1, 0
    .asciiz "MY SCANNERS SAY I JUST RAN INTO ", GUY_FIRST, " ", GUY_LAST, " BUT THAT CORPORATE LOGO ON YOUR SHIP HAS ME CONFUSED."
    .byte 0, 1
    .asciiz "WHAT CAN I SAY, THEY LURED ME IN WITH THE 401K AND FREE GYM MEMBERSHIP."
    .byte 1, 1
    .asciiz "I'LL BE DAMNED. DIDN'T THINK ANYONE COULD MAKE YOU AN HONEST MAN, BUT I DOUBT THERE'S ANYTHING HONEST ABOUT IT."
    .byte 0, 0
    .asciiz "I'M JUST KEEPING MY HEAD DOWN UNTIL MY TOUR IS DONE."
    .byte 1, 1
    .byte "I HEARD ABOUT THE COLONISTS. THAT'S QUITE SOME KINDNESS FROM MR. ", 34, "IT'S EVERY MAN FOR HIMSELF", 34, ".", 0 ; need null if using .byte
    .byte 0, 0
    .asciiz "I GUESS I'M A REAL BLEEDING HEART NOW."
    .byte 254
    .byte 1, 0
    .asciiz "BE CAREFUL OUT THERE ", GUY_FIRST, ". DEEP SCAVENGING IS NO JOKE. EVEN FOR YOU."
    .byte 0, 0
    .asciiz "I FIND THAT EVERY SITUATION BENEFITS FROM A LITTLE HUMOR."
    .byte 1, 1
    .asciiz "I KNOW YOU DO. JUST PROMISE ME YOU WON'T TAKE EXCESSIVE RISKS. YOU STILL OWE ME A DRINK."
    .byte 0, 0
    .asciiz "NOW THAT'S SOMETHING WORTH STAYING ALIVE FOR."
    .byte 1, 0
    .asciiz "I'LL SEE YA AROUND ", GUY_FIRST, ". I KNOW YOU'RE NOT ONE TO ASK FOR HELP, BUT PING ME IF YOU GET IN A JAM."
    .byte 0, 0
    .asciiz "...THANKS..."
    .byte 255

.endif