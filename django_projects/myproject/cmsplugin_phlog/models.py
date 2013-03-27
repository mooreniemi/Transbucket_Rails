from datetime import datetime

from django.db import models
from django.template.loader import select_template
from django.utils.translation import ugettext_lazy as _

from cms.models import CMSPlugin

from photologue.models import Gallery, Photo
from photologue.models import TagField, tagfield_help_text, LATEST_LIMIT



class OrderedGallery(models.Model):
    date_added = models.DateTimeField(_('date published'), default=datetime.now)
    title = models.CharField(_('title'), max_length=100, unique=True)
    title_slug = models.SlugField(_('title slug'), unique=True,
                                  help_text=_('A "slug" is a unique '
                                              'URL-friendly title for an '
                                              'object.'))
    description = models.TextField(_('description'), blank=True)
    is_public = models.BooleanField(_('is public'), default=True,
                                    help_text=_('Public galleries will be '
                                                'displayed in the default '
                                                'views.'))
    photos = models.ManyToManyField(Photo, related_name='ordered_galleries',
                                    verbose_name=_('photos'), null=True,
                                    blank=True, through='PhotoOrdering')
    tags = TagField(help_text=tagfield_help_text, verbose_name=_('tags'))

    class Meta:
        ordering = ['-date_added']
        get_latest_by = 'date_added'
        verbose_name = _('ordered gallery')
        verbose_name_plural = _('ordered galleries')
        app_label= 'photologue'

    def __unicode__(self):
        return self.title

    def __str__(self):
        return self.__unicode__()

    def get_absolute_url(self):
        return reverse('pl-ordered-gallery', args=[self.title_slug])

    def latest(self, limit=LATEST_LIMIT, public=True):
        if not limit:
            limit = self.photo_count()
        if public:
            return self.public()[:limit]
        else:
            return self.photos.all()[:limit]

    def sample(self, count=0, public=True):
        if count == 0 or count > self.photo_count():
            count = self.photo_count()
        if public:
            photo_set = self.public()
        else:
            photo_set = self.photos.all()
        return random.sample(photo_set, count)
    
    def in_order(self, limit=None, public=True):
        photos = self.photos.order_by('photoordering__order')
        if public:
            photos = photos.filter(is_public=True)
        if limit:
            photos = photos[:limit]
        return photos

    def photo_count(self, public=True):
        if public:
            return self.public().count()
        else:
            return self.photos.all().count()
    photo_count.short_description = _('count')

    def public(self):
        return self.photos.filter(is_public=True)

class PhotoOrdering(models.Model):
    photo = models.ForeignKey(Photo)
    gallery = models.ForeignKey(OrderedGallery)
    order = models.PositiveIntegerField(blank=False, default=9999)
    
    class Meta:
        app_label = 'photologue'
        verbose_name = 'photo'

class PhlogGalleryPlugin(CMSPlugin):
    gallery = models.ForeignKey(OrderedGallery)
    order = models.CharField(max_length=32,
                             default='gallery',
                             choices=(('date', 'By Date',),
                                      ('gallery', 'Gallery Order',),
                                      ('random','Random order')))
    limit = models.PositiveIntegerField(default=0,
                                        help_text=u'0 means no limit')
    public = models.BooleanField(default=True)
    template = models.CharField(max_length=255, blank=True,
                                help_text=u'Enter a template to us instead of '
                                u'the standard templates')
    
    @property
    def render_template(self):
        if self.template:
            return self.template
        
        return select_template([
            'cms/plugins/phlog/%s-gallery.html' % (self.placeholder.slot.lower(),),
            'cms/plugins/phlog/gallery.html'])
    
    def copy_relations(self, oldinstance):
        self.gallery = oldinstance.gallery

