function validate_regex(v, pattern){
    var regex = new RegExp(pattern);
    return regex.test(v);          
}
