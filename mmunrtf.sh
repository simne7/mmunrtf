#!/bin/bash

HEAD=$(cat <<-END
<!DOCTYPE html>
<html lang="en-US">
 <head>
  <meta charset="UTF-8"/>
   <style>
    h1,h2,h3,h4,h5,h6,ul,ol,span {
     font-family: "source sans pro", sans-serif;
     margin: 0;
    }
    .heading {
     font-size: 3em;
     font-weight: bold;
     text-decoration: underline;
    }
    h1 {
     margin-top: 32px;
    }
    h2 {
     margin-top: 24px;
    }
    h3 {
     margin-top: 16px;
     color: #555;
    }
    h4{
     margin-top: 8px;
     font-style: italic;
    }
    ol {
    }
    ul {
    }
   </style>
   <title>$1 &gt; HTML</title>
 </head>
 <body>
END
)

FOOT=$(cat <<-END
 </body>
</html>
END
)

if [ -f "$1" ]; then

    echo -e "$HEAD"

    # grep all lines with a 'li600' statement at the end
    # then delete all lines (begin with a "{")
    # then delete all separator lines
    # then replace the liXXX expressions with one newline and tabs
    # then replace german umlauts and strange RTF separators ("\'3f")
    plain=$(grep -A 2 -E "li[0-9]+$" "$1" | \
                sed '/^{/d' | \
                sed '/^--/d' | \
                sed 's/\\li200/\n\t/g' | \
                sed 's/\\li400/\n\t\t/g' | \
                sed 's/\\li600/\n\t\t\t/g' | \
                sed 's/\\li800/\n\t\t\t\t/g' | \
                sed 's/\\li1000/\n\t\t\t\t\t/g' | \
                sed 's/\\li1200/\n\t\t\t\t\t\t/g' | \
                sed 's/\\li1400/\n\t\t\t\t\t\t\t/g' | \
                sed -E ':a;N;$!ba;s/\t\n/\t/g' | \
                sed '/^\\slm/d' | \
                sed 's/\\u228/ä/g' | \
                sed 's/\\u228/ä/g' | \
                sed 's/\\u246/ö/g' | \
                sed 's/\\u252/ü/g' | \
                sed 's/\\u196/Ä/g' | \
                sed 's/\\u214/Ö/g' | \
                sed 's/\\u220/Ü/g' | \
                sed 's/\\u223/ß/g' | \
                sed 's/\\'"'"'3f//g')

    last_indent=-1
    closing_tags=""
    IFS=$'\n'
    for line in $plain; do
        indent=$(echo "$line" | grep -o $'\t' | wc -l)
        # trim leading and trailing spaces
        line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"


        if [ $indent -lt $last_indent ]; then
            delta=$((last_indent-indent))
            #debug="<!-- closing, delta: $delta\n"
            IFS=',' read -r -a array <<< "$closing_tags"
            #echo -e "${array[@]: 0:$delta}"
            closing_tags=""
            for idx in "${!array[@]}"; do
                if [ $idx -ge $delta ]; then
                    closing_tags="$closing_tags,${array[$idx]}"
                else
                    echo -e "${array[$idx]}"
                fi
            done
            closing_tags="${closing_tags:1}"
            #debug="$debug $closing_tags -->"
            #echo "$debug"
        fi

        case $indent in
            0) line="<span class='heading'>$line</span>" ;;
            1) line=" <h1>$line</h1>" ;;
            2) line="  <h2>$line</h2>" ;;
            3) line="   <h3>$line</h3>"
                #if [ $indent -gt $last_indent ]; then
                #    line="   <ol>\n    <li>$line"
                #    closing_tags="    </li>\n   </ol>,$closing_tags"
                #else
                #    line="    </li>\n    <li>$line"
                #fi
                ;;
            4)
                if [ $indent -gt $last_indent ]; then
                    line="     <ul>\n      <li>$line"
                    closing_tags="      </li>\n     </ul>,$closing_tags"
                else
                    line="      </li>\n      <li>$line"
                fi
                ;;
            *)
                line="<br>... $line"
                ;;
        esac

        if [ $indent -lt 5 ]; then
            last_indent=$indent
        fi
        echo -e "$line"
        cnt=$((cnt+1))
    done

    IFS=',' read -r -a array <<< "$closing_tags"
    for idx in "${!array[@]}"; do
        echo -e "${array[$idx]}"
    done

    echo -e "$FOOT"

else
    echo "Not a file '$1'"
fi
