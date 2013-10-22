$('#dataset-upload').change(function(e) {
    var filepath = this.value;
    var m = filepath.match(/([^\/\\]+)$/);
    var filename = m[1];
    $('.dataset-filename').text(filename);
});