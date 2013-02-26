var toggleForm = function (ui, id) {
  form = document.getElementById('comment-form-' + id)
  if (form.style.display === 'none') {
    console.log('showing...');
    form.style.display = 'block';
    ui.innerHTML = 'hide';
  } else {
    console.log('hiding...');
    form.style.display = 'none';
    ui.innerHTML = 'comment';
  }
}