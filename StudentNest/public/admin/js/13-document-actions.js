document.addEventListener('click', async (event) => {
  const target = event.target.closest('button, [data-admin-access], [data-delete-admin]');
  if (!target) return;

  if (target.dataset.tab) {
    setTab(target.dataset.tab);
    return;
  }

  if (target.dataset.tabShortcut) {
    setTab(target.dataset.tabShortcut);
    return;
  }

  if (target.dataset.adminStats) {
    await openAdminStatsPage(target.dataset.adminStats);
    return;
  }

  if (target.dataset.refresh !== undefined) {
    await loadDashboard();
    showToast('Dashboard refreshed.');
    return;
  }

  if (target.dataset.detail) {
    await showDetail(target.dataset.detail, target.dataset.id);
    return;
  }

  if (target.dataset.photoIndex) {
    showPhotoAt(Number(target.dataset.photoIndex));
    return;
  }

  if (target.dataset.landlordStatus) {
    const approved = target.dataset.approved === 'true';
    const reason = await confirmAction({
      title: approved ? 'Approve landlord?' : 'Suspend landlord?',
      message: approved
        ? 'This landlord will be able to use the landlord app features.'
        : 'This will remove approval from the landlord. Add a note for your internal workflow.',
      needsReason: !approved,
      confirmLabel: approved ? 'Approve' : 'Suspend',
    });
    if (reason === null) return;
    // TODO: Persist moderation notes when the backend has audit/note columns.
    await runAction(
      () => api(`/api/admin/landlords/${target.dataset.landlordStatus}`, {
        method: 'PATCH',
        body: JSON.stringify({ is_approved: approved }),
      }),
      approved ? 'Landlord approved.' : 'Landlord suspended.',
    );
    return;
  }

  if (target.dataset.propertyStatus) {
    const approved = target.dataset.approved === 'true';
    const reason = await confirmAction({
      title: approved ? 'Approve property?' : 'Reject property?',
      message: approved
        ? 'Students will be able to see this property when it is active.'
        : 'This property will return to pending/rejected workflow. Add a reason for your records.',
      needsReason: !approved,
      confirmLabel: approved ? 'Approve' : 'Reject',
    });
    if (reason === null) return;
    // TODO: Persist rejection reasons when the backend has moderation note fields.
    await runAction(
      () => api(`/api/admin/properties/${target.dataset.propertyStatus}`, {
        method: 'PATCH',
        body: JSON.stringify({ is_approved: approved }),
      }),
      approved ? 'Property approved.' : 'Property rejected.',
    );
    return;
  }

  if (target.dataset.propertyVerify) {
    const verified = target.dataset.verified === 'true';
    const note = await confirmAction({
      title: verified ? 'Verify property?' : 'Remove verification?',
      message: verified
        ? 'Only verify after you have inspected the property or checked proof of ownership. Students will see a "Verified" badge. Add a note on how it was checked.'
        : 'Students will no longer see the "Verified" badge on this listing. Add a reason for your records.',
      needsReason: true,
      confirmLabel: verified ? 'Verify' : 'Remove badge',
    });
    if (note === null) return;
    await runAction(
      () => api(`/api/admin/properties/${target.dataset.propertyVerify}/verification`, {
        method: 'PATCH',
        body: JSON.stringify({ verified, note }),
      }),
      verified ? 'Property verified.' : 'Verification removed.',
    );
    return;
  }

  if (target.dataset.listingPeriod) {
    const live = target.dataset.live === 'true';
    const answer = await confirmAction({
      title: live ? 'Extend listing?' : 'Reactivate listing?',
      message: live
        ? 'Adds time to this listing without a payment. The extra time starts when the current period ends.'
        : 'Makes this listing visible to students again without a payment, starting today. Use this for demo listings, complimentary periods or corrections; landlords can also renew by paying in the app.',
      choice: {
        label: live ? 'Add' : 'Show to students for',
        value: '30',
        options: [
          { value: '7', label: '7 days' },
          { value: '14', label: '14 days' },
          { value: '30', label: '30 days' },
          { value: '90', label: '3 months' },
          { value: '180', label: '6 months' },
          { value: '365', label: '12 months' },
        ],
      },
      needsReason: true,
      confirmLabel: live ? 'Extend' : 'Reactivate',
    });
    if (answer === null) return;
    await runAction(
      () => api(`/api/admin/properties/${target.dataset.listingPeriod}/listing-period`, {
        method: 'PATCH',
        body: JSON.stringify({ days: Number(answer.choice), reason: answer.reason }),
      }),
      live ? 'Listing extended.' : 'Listing reactivated.',
    );
    return;
  }

  if (target.dataset.deleteLandlord) {
    const confirmed = await confirmAction({
      title: 'Delete landlord?',
      message: 'This is destructive and removes the landlord account from the app.',
      confirmLabel: 'Delete',
    });
    if (confirmed === null) return;
    await runAction(
      () => api(`/api/admin/landlords/${target.dataset.deleteLandlord}`, { method: 'DELETE' }),
      'Landlord deleted.',
    );
    return;
  }

  if (target.dataset.deleteProperty) {
    const confirmed = await confirmAction({
      title: 'Delete property?',
      message: 'This is destructive and removes the property listing.',
      confirmLabel: 'Delete',
    });
    if (confirmed === null) return;
    await runAction(
      () => api(`/api/admin/properties/${target.dataset.deleteProperty}`, { method: 'DELETE' }),
      'Property deleted.',
    );
    return;
  }

  if (target.dataset.adminAccess) {
    event.preventDefault();
    event.stopPropagation();
    const accessLevel = target.dataset.access;
    const confirmed = await confirmAction({
      title: accessLevel === 'owner' ? 'Give full owner access?' : 'Move admin to manager access?',
      message:
        accessLevel === 'owner'
          ? 'This admin will be able to create admins, change admin access, and delete manager admins.'
          : 'This admin will keep operational access but lose owner-level account controls.',
      confirmLabel: 'Update access',
    });
    if (confirmed === null) return;
    await runAction(
      () =>
        api(`/api/admin/admins/${target.dataset.adminAccess}/access`, {
          method: 'PATCH',
          body: JSON.stringify({ access_level: accessLevel }),
        }),
      'Admin access updated.',
    );
    return;
  }

  if (target.dataset.deleteAdmin) {
    event.preventDefault();
    event.stopPropagation();
    const confirmed = await confirmAction({
      title: 'Delete admin account?',
      message: 'This removes the admin from web admin access. Owner admins cannot be deleted.',
      confirmLabel: 'Delete admin',
    });
    if (confirmed === null) return;
    await runAction(
      () =>
        api(`/api/admin/admins/${target.dataset.deleteAdmin}`, {
          method: 'DELETE',
        }),
      'Admin account deleted.',
    );
  }
});

