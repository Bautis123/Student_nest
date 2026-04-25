els.profileForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  const formData = new FormData(event.currentTarget);
  await runAction(
    () =>
      api('/api/admin/profile', {
        method: 'PATCH',
        body: JSON.stringify({
          full_name: formData.get('full_name'),
          email: formData.get('email') || null,
        }),
      }),
    'Profile updated.',
  );
  els.profileModal.close();
});

els.adminAccountForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  const formData = new FormData(event.currentTarget);
  await runAction(
    () =>
      api('/api/admin/create-admin', {
        method: 'POST',
        body: JSON.stringify({
          full_name: formData.get('full_name'),
          phone: formData.get('phone'),
          email: formData.get('email') || null,
          password: formData.get('password'),
          access_level: formData.get('access_level'),
        }),
      }),
    'Admin account created.',
  );
  els.adminAccountModal.close();
  event.currentTarget.reset();
});

els.paymentForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  const formData = new FormData(event.currentTarget);
  const propertyId = formData.get('property_id');
  const selectedProperty = state.data.properties.find(
    (property) => String(property.id) === String(propertyId),
  );
  const payload = {
    landlord_id: selectedProperty?.landlord_id || formData.get('landlord_id'),
    property_id: propertyId,
    amount: Number(formData.get('amount')),
    payment_method: formData.get('payment_method'),
    mobile_money_provider: formData.get('mobile_money_provider'),
    bank_name: formData.get('bank_name'),
    payment_reference: formData.get('payment_reference'),
    duration_months: Number(formData.get('duration_months')),
    status: formData.get('status'),
  };

  if (!payload.property_id) {
    showToast('Choose a property before saving.', 'error');
    return;
  }

  await runAction(
    () =>
      api('/api/admin/payments', {
        method: 'POST',
        body: JSON.stringify(payload),
      }),
    'Payment recorded.',
  );
  els.paymentModal.close();
  event.currentTarget.reset();
});

document.addEventListener('keydown', (event) => {
  if (!els.photoViewer.open) return;
  if (event.key === 'Escape') els.photoViewer.close();
  if (event.key === 'ArrowLeft') showPhotoAt(activePhotoIndex - 1);
  if (event.key === 'ArrowRight') showPhotoAt(activePhotoIndex + 1);
});

