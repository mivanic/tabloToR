processSetStatement = function(s) {
  # SET READ
  if (grepl(".* maximum size .* read elements from file .* header \"*\"",
            s$command)) {
    words = strsplit(s$command, " ")[[1]]
    #toRet[[words[1]]] = files[[words[9]]][[gsub("\"", "", words[11])]]
    toRet = sprintf('%s=%s$%s', words[[1]], words[[9]], gsub("\"", "", words[11]))
  }
  else if (grepl(".* read elements from file .* header \"*\"",
            s$command)) {
    words = strsplit(s$command, " ")[[1]]
    #toRet[[words[1]]] = files[[words[9]]][[gsub("\"", "", words[11])]]
    toRet = sprintf('%s=%s$%s', words[[1]], words[[6]], gsub("\"", "", words[8]))
  }
  # SET DIFFERENCE
  else if (grepl(".* = .* - .*", s$command)) {
    command = str2lang(s$command)
    command[[3]][[1]] = as.name('setdiff')
    #toRet[[deparse(command[[2]])]] = eval(command[[3]], toRet)
    toRet = sprintf('%s=%s', deparse1(command[[2]]), deparse1(command[[3]]))
  }
  # SET UNION
  else if (grepl(".* = .* union .*", s$command)) {
    command = str2lang(gsub('union', '+', s$command))
    command[[3]][[1]] = as.name('union')
    #toRet[[deparse(command[[2]])]] = eval(command[[3]], toRet)
    toRet = sprintf('%s=%s', deparse1(command[[2]]), deparse1(command[[3]]))
  }
  # SET INTERSECTION
  else if (grepl(".* = .* intersect .*", s$command)) {
    command = str2lang(gsub('intersect', '+', s$command))
    command[[3]][[1]] = as.name('intersect')
    #toRet[[deparse(command[[2]])]] = eval(command[[3]], toRet)
    toRet = sprintf('%s=%s', deparse1(command[[2]]), deparse1(command[[3]]))
  }
  # SET FORMULA
  else if (grepl(".* = \\(all,.*,.*\\)", s$command)) {
    preCommand = str2lang(gsub(":", ",", gsub("\\(all,", "all(", gsub('>==','>=',gsub('<==','<=',gsub('=','==',s$command))))))

    setName = deparse1(preCommand[[3]][[3]])
    standIn = deparse1(preCommand[[3]][[2]])
    preCommand[[3]][[4]] = str2lang(gsub(
      paste0('\\b', standIn, '\\b'),
      setName ,
      deparse1(preCommand[[3]][[4]])
    ))

    preCommand[[3]][[1]] = as.name('[')
    preCommand[[3]][[2]] = NULL

    preCommand[[3]][[3]] = removeFunctions(preCommand[[3]][[3]])

    #toRet[[deparse(preCommand[[2]])]] = eval(preCommand[[3]], toRet)
    toRet = sprintf('%s=%s', deparse1(preCommand[[2]]), deparse1(preCommand[[3]]))
    #eval(str2lang('SLUG[ENDW_COMM]'), toRet)
    #eval(quote(SLUG[ENDW_COMM]),toRet)
  }
  # SET SPECIFIED
  else if (grepl(".* \\(.*\\)", s$command)) {
    from = regexpr('\\(', s$command)
    to = regexpr('\\)', s$command)
    elements = strsplit(substr(s$command, from + 1, to - 1), ',')[[1]]

    #toRet[[trimws(substr(s$command, 1, from - 1))]] = elements
    toRet = sprintf('%s=c(%s)',
                    trimws(substr(s$command, 1, from - 1)),
                    paste('"', elements, '"', sep = '', collapse = ','))
  }

  return(toRet)
}
